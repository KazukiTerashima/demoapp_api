require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = active_user
  end

  test "name_validation" do
    # 入力必須
    user = User.new(email: "test@example.com", password: "password")
    user.save
    required_msg = ["名前を入力してください"]
    assert_equal(required_msg, user.errors.full_messages)
    # 文字数制限
    max = 30
    name = "a" * (max + 1)
    assert max < name.length

    user.name = name
    user.save
    too_long_msg = ["名前は30文字以内で入力してください"]
    assert_equal(too_long_msg, user.errors.full_messages)
    # 入力が正しい場合保存されるか
    user.name = "a" * max
    assert_difference("User.count", 1) do
      user.save
    end
  end

  test "email_validation" do
    # 入力必須
    user = User.new(name: "test", password: "password")
    user.save
    required_msg = ["メールアドレスを入力してください"]
    assert_equal(required_msg, user.errors.full_messages)
    # 文字数制限
    max = 255
    domain = "@example.com"
    email =  "a" * (max + 1 - domain.length) + domain
    assert max < email.length
    user.email =  "a" * (max + 1 - domain.length) + domain
    user.save
    too_long_msg = ["メールアドレスは255文字以内で入力してください"]
    assert_equal(too_long_msg, user.errors.full_messages)
    # # 正しい書式
    valid_emails = %w(
      A@EX.COM
      a-_@e-x.c-o_m.j_p
      a.a@ex.com
      a@e.co.js
      1.1@ex.com
      a.a+a@ex.com
    )
    valid_emails.each do |valid_email|
      user.email = valid_email
      assert user.save
    end
    # 不正な書式
    invalid_emails = %w(
      aaa
      a.ex.com
      メール@ex.com
      a~a@ex.com
      a@|.com
      a@ex.
      .a@ex.com
      a＠ex.com
      Ａ@ex.com
      a@?,com
      １@ex.com
      "a"@ex.com
      a@ex@co.jp
    )
    invalid_emails.each do |invalid_email|
      user.email = invalid_email
      user.save
      invalid_msg = ["メールアドレスは不正な値です"]
      assert_equal(invalid_msg, user.errors.full_messages)
    end
  end

  test "email_downcase" do
    email = "EXAMPLE@TEST.COM"
    user = User.new(email: email)
    user.save
    assert user.email == email.downcase
  end

  test "activated_user_validation" do
    # アクティブユーザーがいない場合、同じメールアドレスを登録できる
    email = "test@example.com"
    count = 3
    assert_difference("User.count", 3) do
      count.times do |n|
        User.create(name: "test", email: email, password: "password")
      end
    end
    # アクティブユーザーがいる場合、同じメールアドレスを登録できない
    activate_user = User.find_by(email: email)
    activate_user.update!(activated: true)
    assert_no_difference("User.count") do
      user = User.new(name: "test", email: email, password: "password")
      user.save
      taken_msg = ["メールアドレスはすでに存在します"]
      assert_equal(taken_msg, user.errors.full_messages)
    end
    # アクティブユーザーがいなくなった場合
    activate_user.destroy!
    assert_difference("User.count", 1) do
      User.create(name: "test", email: email, password: "password", activated: true)
    end
    # 一意性
    assert_equal(1, User.where(email: email, activated: true).count)
  end

  test "password_validation" do
    # 入力必須
    user = User.new(name: "test", email: "test@example.com")
    user.save
    required_msg = ["パスワードを入力してください"]
    assert_equal(required_msg, user.errors.full_messages)
    # 文字数制限
    min = 8
    password =  "a" * (min - 1)
    assert min > password.length
    user.password =  password
    user.save
    too_short_msg = ["パスワードは8文字以上で入力してください"]
    assert_equal(too_short_msg, user.errors.full_messages)
    # 正しい書式
    valid_passwords = %w(
      pass---word
      ________
      12341234
      ____pass
      pass----
      PASSWORD
    )
    valid_passwords.each do |valid_password|
      user.password = valid_password
      assert user.save
    end
    # 不正な書式
    invalid_passwords = %w(
      pass/word
      pass.word
      |~=?+"a"
      １２３４５６７８
      ＡＢＣＤＥＦＧＨ
      password@
    )
    invalid_passwords.each do |invalid_password|
      user.password = invalid_password
      user.save
      invalid_msg = ["パスワードは半角英数字、-(ハイフン)、_(アンダーバー)のみ使用できます"]
      assert_equal(invalid_msg, user.errors.full_messages)
    end
  end
end
