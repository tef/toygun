require 'spec_helper'
require 'date'

describe Toygun::Codec do
  let(:codec) { Toygun::RecordCodec.new }

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
      t = {"a" => x}
      enc_t = codec.dump_hash(t)
      dec_t = codec.parse_hash(enc_t)
      fin_t = codec.dump_hash(dec_t)
      expect(t).to eq(dec_t)
      expect(fin_t).to eq(enc_t)
    end
  end
end
