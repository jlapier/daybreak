require File.expand_path(File.dirname(__FILE__)) + '/test_helper.rb'

describe "benchmarks" do
  before do
    @db = Daybreak::DB.new DB_PATH
    1000.times {|i| @db[i] = i }
    @db.flush!
    @db = Daybreak::DB.new DB_PATH
  end

  bench_performance_constant "keys with sync" do |n|
    n.times {|i| @db.set(i, 'i' * i, true) }
  end

  bench_performance_constant "inserting keys" do |n|
    n.times {|i| @db[i] = 'i' * i }
  end

  bench_performance_constant "reading keys" do |n|
    n.times {|i| assert_equal i % 1000, @db[i % 1000] }
  end

  after do
    @db.empty!
    @db.close!
    File.unlink(DB_PATH)
  end
end

require 'pstore'

describe "compare with pstore" do
  before do
    @pstore = PStore.new(File.join(HERE, "test.pstore"))
  end

  bench_performance_constant "pstore bulk performance" do |n|
    @pstore.transaction do
      n.times do |i|
        @pstore[i] = 'i' * i
      end
    end
  end

  after do
    File.unlink File.join(HERE, "test.pstore")
  end
end

require 'dbm'

describe "compare with dbm" do
  before do
    @dbm = DBM.open(File.join(HERE, "test-dbm"), 666, DBM::WRCREAT)
    1000.times {|i| @dbm[i.to_s] = i }
  end

  bench_performance_constant "DBM write performance" do |n|
    n.times do |i|
      @dbm[i.to_s] = 'i' * i
    end
  end

  bench_performance_constant "DBM read performance" do |n|
    n.times do |i|
      assert_equal (i % 1000).to_s, @dbm[(i % 1000).to_s]
    end
  end

  after do
    @dbm.close

    File.unlink File.join(HERE, "test-dbm.db")
  end
end