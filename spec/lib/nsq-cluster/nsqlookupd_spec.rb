require_relative '../../spec_helper'

describe Nsqlookupd do

  describe '::new' do
    it 'should have tcp_port and http_port set by default' do
      nsqd = Nsqlookupd.new
      expect(nsqd.tcp_port).to eq(4160)
      expect(nsqd.http_port).to eq(4161)
    end

    it 'should set tcp_port and http_port based on id if they\'re not specified' do
      id = 5
      nsqd = Nsqlookupd.new(id: id)
      expect(nsqd.tcp_port).to eq(4160 + id * 2)
      expect(nsqd.http_port).to eq(4161 + id * 2)
    end
  end

  describe '#args' do
    it 'includes arbitrary options passed in to the constructor' do
      nsqd = Nsqlookupd.new(some_random_flag: '60s')
      arg = '--some-random-flag=60s'
      expect(nsqd.args.include?(arg)).to eq(true)
    end
  end

  describe 'while running' do
    before do
      @cluster = NsqCluster.new(nsqd_count: 1, nsqlookupd_count: 1)
      @nsqd = @cluster.nsqd.first
      @nsqlookupd = @cluster.nsqlookupd.first
      @nsqlookupd.block_until_running
    end

    after do
      @cluster.destroy
    end

    describe 'api endpoints' do
      describe '#ping' do
        it 'should return status 200' do
          expect(@nsqlookupd.ping.code).to eql('200')
        end
      end

      describe '#info' do
        it 'should return status 200' do
          expect(@nsqlookupd.info.code).to eql('200')
        end
      end

      describe '#nodes' do
        it 'should return status 200' do
          expect(@nsqlookupd.nodes.code).to eql('200')
        end
      end

      describe '#topic' do
        it 'should return status 200' do
          expect(@nsqlookupd.topics.code).to eql('200')
        end
      end

      describe '#channels' do
        it 'should return status 200' do
          expect(@nsqlookupd.channels('default').code).to eql('200')
        end
      end

      describe '#lookup' do
        describe 'an existing topic' do
          before do
            @nsqd.create(topic: 'test')
          end

          it 'should return status 200' do
            expect(@nsqlookupd.lookup('test').code).to eql('200')
          end
        end

        describe 'a non-existant topic' do
          it 'should return status 500' do
            expect(@nsqlookupd.lookup('wtf').code).to eql('500')
          end
        end
      end
    end
  end
end
