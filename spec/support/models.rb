ActiveRecord::Base.establish_connection(
  adapter:   'mysql2',
  database:  "full_table_scan_matchers_test",
  host:      "localhost",
  username:  "root",
  password:  ""
)

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
  end

  create_table :posts, force: true do |t|
    t.belongs_to :user, index: true
  end

  create_table :unindexed_posts, force: true do |t|
    t.belongs_to :user, index: false
  end

  create_table :comments, force: true do |t|
    t.belongs_to :post, index: false
    t.belongs_to :user, index: false
  end
end

class User < ActiveRecord::Base
  has_many :posts
  has_many :unindexed_posts
  has_many :comments
end

class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments
end

class UnindexedPost < ActiveRecord::Base
  belongs_to :user
end

class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
end
