require 'spec_helper'

RSpec.describe Netrcx do
  let :fixture do
    <<~TEXT
      machine a.com
        login s3cret
      machine b.com
        login userb
        password passb
      machine c.com
        login 'domain\\user'
        password passc
        account workgroup
      default
        login me
    TEXT
  end

  it 'should parse' do
    netrc = Netrcx.new(fixture)
    expect(netrc.default).to eq(Netrcx::Entry.new(default: true, login: 'me'))
    expect(netrc.entries).to eq [
      Netrcx::Entry.new(default: false, host: 'a.com', login: 's3cret'),
      Netrcx::Entry.new(default: false, host: 'b.com', login: 'userb', password: 'passb'),
      Netrcx::Entry.new(default: false, host: 'c.com', login: 'domain\\user', password: 'passc', account: 'workgroup'),
      Netrcx::Entry.new(default: true, login: 'me'),
    ]
  end

  it 'should read from file' do
    temp = Tempfile.new
    temp.write fixture
    temp.close

    netrc = Netrcx.read(temp.path)
    expect(netrc.entries.size).to eq(4)
  end

  it 'should skip comments' do
    data = <<~TEXT
      machine a.com login x
      # machine b.com login y
      machine c.com
        # login old
        login z #password follows
        password # next line
          s3cret
    TEXT

    netrc = Netrcx.new(data)
    expect(netrc.default).to be_nil
    expect(netrc.entries).to eq [
      Netrcx::Entry.new(default: false, host: 'a.com', login: 'x'),
      Netrcx::Entry.new(default: false, host: 'c.com', login: 'z', password: 's3cret'),
    ]
  end
end
