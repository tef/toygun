require 'spec_helper'
require 'date'

describe Toygun::Codec do
  let(:codec) { Toygun::Codec.new }

  it "encodes" do
    things = [
      -1,
      0,
      1,
      1.2,
      "Foo",
      :foo,
      [1,2,3],
      {"a" => 1, "b" => 2},
      "",
      Time.now.round,
    ]
    things.each do |x|
      t = [x]
      enc_t = codec.dump(t)
      dec_t = codec.parse(enc_t)
      fin_t = codec.dump(dec_t)
      expect(t).to eq(dec_t)
      expect(fin_t).to eq(enc_t)
    end
  end
end
