class Public::ContactsController < ApplicationController
  # 新規お問い合わせフォームの表示
  def new
    # 新しいContactインスタンスを作成し、ビューに渡す
    @contact = Contact.new
  end

  # 入力内容確認画面の表示
  def confirm
    # フォームから送信されたデータを使って、新しいContactインスタンスを作成
    @contact = Contact.new(contact_params)

    # バリデーションエラーがあれば、エラーメッセージを表示して再度新規フォームに戻る
    if @contact.invalid?
      flash[:alert] = @contact.errors.full_messages.join(", ")  # エラーメッセージをフラッシュに格納
      @contact = Contact.new  # 新しいインスタンスを作り直すことで入力内容をクリア
      render :new  # 新規フォームに戻る
    end
  end

  # 「入力内容確認」画面から「戻る」ボタンが押された場合の処理
  def back
    # フォームから送信されたデータを使って、新しいContactインスタンスを作成
    @contact = Contact.new(contact_params)
    render :new  # 新規フォームを再表示
  end

  # お問い合わせフォームのデータを保存し、メールを送信
  def create
    # フォームから送信されたデータを使って、新しいContactインスタンスを作成
    @contact = Contact.new(contact_params)

    # データが正常に保存できた場合
    if @contact.save
      # メールを送信
      ContactMailer.contact_mail(@contact).deliver_now
      # 成功した場合は「完了ページ」へリダイレクト
      redirect_to done_public_contacts_path
    else
      # 保存に失敗した場合、エラーメッセージを表示し再度新規フォームを表示
      flash[:alert] = @contact.errors.full_messages.join(", ")
      @contact = Contact.new  # 新しいインスタンスを作成してフォームをリセット
      render :new  # 新規フォームに戻る
    end
  end

  # 完了画面の表示
  def done
    # 完了画面では特に何もする必要はないため、ビューファイルが表示される
  end

  private

  # フォームから送信されるパラメータを許可する
  def contact_params
    params.require(:contact).permit(:name, :message, :subject, :email)
  end
end
