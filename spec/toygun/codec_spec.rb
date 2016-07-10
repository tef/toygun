require 'spec_helper'
require 'date'

describe Toygun::Codec do
  let(:codec) { Toygun::JsonObjectCodec.new }

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
      {},
      "",
      Time.now.round,
    ]
    things.each do |x|
      t = {a: x}
      enc_t = codec.dump_json(t).to_json
      dec_t = codec.parse_json(JSON.parse(enc_t))
      fin_t = codec.dump_json(dec_t).to_json
      expect(t).to eq(dec_t)
      expect(fin_t).to eq(enc_t)
    end
  end
end
