require 'spec_helper'

describe "#full_table_scan" do
  let!(:user)           { User.create! }
  let!(:post)           { Post.create! user_id: user.id }
  let!(:unindexed_post) { UnindexedPost.create! user_id: user.id }
  let!(:comment)        { Comment.create! user_id: user.id, post_id: post.id }

  it "handles basic cases" do
    expect { user.posts.to_a }.not_to full_table_scan
    expect { user.unindexed_posts.to_a }.to full_table_scan
  end

  it "cases with joins and multiple explains" do
    expect { user.posts.joins(:comments).first.comments }.to full_table_scan
    expect { user.posts.joins(:comments).first.comments }.not_to full_table_scan.on :posts
    expect { user.posts.joins(:comments).first.comments }.to full_table_scan.on :comments
  end
end
