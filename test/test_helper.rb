require "bundler"
Bundler.setup(:default, :test)

require "minitest/autorun"
require "webmock/minitest"

$:.unshift(Dir.pwd)

require "lib/category"
require "lib/product"
require "lib/variable_product"

module Fixtures
  def json_fixture(name)
    JSON.parse(File.read(File.join("test", "fixtures", "#{name}.json")))
  end
end

module ProductHelpers
  def simple_product(attrs = {})
    Product.new({ "name" => "Test product", "airtable_id" => "id-1" }.merge(attrs))
  end

  def variation(attrs = {})
    Product.new({
      "name" => "Test",
      "variant" => "Variant",
      "airtable_id" => "id-2"
    }.merge(attrs))
  end

  def variable_product
    VariableProduct.new([variation])
  end

  def synced_product(product)
    product.update("last_sync_data" => product.sync_data)
  end
end
