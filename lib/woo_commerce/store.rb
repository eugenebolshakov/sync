require "woocommerce_api"

module WooCommerce
  class Store
    def initialize(api: WooCommerce::API, url:, key:, secret:, debug: false)
      api_params = [url, key, secret]
      if debug
        params << { httparty_args: { debug_output: $stdout } }
      end
      @api = api.new(*api_params)
    end

    def update_simple_product(product)
      params = {
        product: {
          title: product.name,
          price: product.price,
          short_description: product.short_description,
          description: "<pre>#{product.long_description}</pre>",
          enable_html_description: true,
          categories: [product.category.woocommerce_id],
          images: product.images.map.with_index { |url, i| { src: url, position: i } }
        }
      }
      response = @api.put("products/#{product.woocommerce_id}", params)
      product.update("woocommerce_id" => response.parsed_response.fetch("product").fetch("id"))
    end

    def update_variable_product(product)
      params = {
        product: {
          title: product.name,
          short_description: product.short_description,
          description: "<pre>#{product.long_description}</pre>",
          enable_html_description: true,
          categories: [product.category.woocommerce_id],
          images: product.images.map.with_index { |url, i| { src: url, position: i } },
          attributes: [
            {
              name: "Option",
              position: 0,
              visible: true,
              variation: true,
              options: product.variants,
            }
          ],
          variations: product.variations.map { |variation|
            {
              regular_price: variation.price,
              image: { src: variation.images[0], position: 0 },
              attributes: [
                {
                  option: variation.variant,
                  name: "Option",
                }
              ]
            }
          }
        }
      }

      response = @api.put("products/#{product.woocommerce_id}", params)
      wc_product = response.parsed_response.fetch("product")
      VariableProduct.new(
        product.variations.zip(wc_product.fetch("variations")).map { |variation, wc_variation|
          variation.update("woocommerce_id" => [wc_product.fetch("id"), wc_variation.fetch("id")].join(":"))
        }
      )
    end
  end
end
