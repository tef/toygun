require 'spec_helper'
require 'date'

describe Toygun::Codec do
  let(:codec) { Toygun::RecordCodec.new }

  it "handles secrets" do
    secret = Toygun::Secret.encrypt("stuff")
    ran = false
    secret.decrypt do |m|
      expect(m).to eq('stuff')
      ran = true
    end
    expect(ran).to eq(true)

  end

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
      enc_t = codec.dump(t).to_json
      dec_t = codec.parse(JSON.parse(enc_t))
      fin_t = codec.dump(dec_t).to_json
      expect(t).to eq(dec_t)
      expect(fin_t).to eq(enc_t)
    end
  end
end
