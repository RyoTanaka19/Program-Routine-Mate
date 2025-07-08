require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    it '有効なユーザーであること' do
      user = build(:user)
      expect(user).to be_valid
    end

    it '名前がないと無効' do
      user = build(:user, name: nil)
      expect(user).to_not be_valid
      expect(user.errors[:name]).to include("を入力してください")
    end

    it 'メールアドレスがないと無効' do
      user = build(:user, email: nil)
      expect(user).to_not be_valid
    end

    it '同じメールアドレスは登録できない（大文字小文字無視）' do
      create(:user, email: "test@example.com")
      user = build(:user, email: "TEST@example.com")
      expect(user).to_not be_valid
      expect(user.errors[:email]).to include("はすでに存在します")
    end

    it 'パスワードがないと無効（通常登録時）' do
      user = build(:user, password: nil, password_confirmation: nil)
      expect(user).to_not be_valid
      expect(user.errors[:password]).to include("を入力してください")
    end

it 'パスワードと確認が一致しないと無効' do
  user = build(:user, password: "password123", password_confirmation: "wrong")
  expect(user).to_not be_valid
  # 部分一致でメッセージをチェックする方法
  expect(user.errors[:password_confirmation].join).to include("一致しません")
end
  end

  describe '.from_omniauth' do
    let(:auth_info) do
      OmniAuth::AuthHash.new({
        provider: "github",
        uid: "123456",
        info: {
          name: "GitHub User",
          email: "github@example.com"
        }
      })
    end

    it "既存ユーザーがproviderとuidで見つかる場合、そのユーザーを返す" do
      existing_user = create(:user, provider: "github", uid: "123456")
      expect(User.from_omniauth(auth_info)).to eq existing_user
    end

    it "メールが一致するユーザーがいればproviderとuidを更新して返す" do
      existing_user = create(:user, email: "github@example.com", provider: nil, uid: nil)
      updated_user = User.from_omniauth(auth_info)
      expect(updated_user).to eq existing_user
      expect(updated_user.provider).to eq "github"
      expect(updated_user.uid).to eq "123456"
    end

    it "新規ユーザーを作成して返す" do
      user = User.from_omniauth(auth_info)
      expect(user).to be_persisted
      expect(user.email).to eq "github@example.com"
      expect(user.provider).to eq "github"
      expect(user.uid).to eq "123456"
    end
  end
end
