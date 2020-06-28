require 'rails_helper'

RSpec.describe User, type: :model do
  # 名前があれば有効な状態であること
  it "is invalid without a name" do
    user = User.new(name: nil, email: "test@email.com", password: "password")
    user.valid?
    expect(user.errors[:name]).to include("を入力してください")
  end
  # メールアドレスがなければ無効な状態であること
  it "is invalid without an email address" do
    user = User.new(name: "aaa", email: nil, password: "password")
    user.valid?
    expect(user.errors[:base]).to eq (["メール認証するかTwitterで認証を行ってください。"])
  end
  # 重複したメールアドレスなら無効な状態であること
  it "is invalid with a duplicate email address" do
    user = User.create(name: "aaa", email: "test@email.com", password: "password")
    duplicate_user = User.new(name: "aaa", email: "test@email.com", password: "password")
    duplicate_user.valid?
    expect(duplicate_user).to be_invalid
  end
end
