require "google/apis/sheets_v4"
require "googleauth"
require "tempfile"

class GoogleSheetsService
  Sheets = Google::Apis::SheetsV4

  def initialize
    @service = Sheets::SheetsService.new
    @service.client_options.application_name = "ProgramRoutineMate"
    @service.authorization = authorize
    @spreadsheet_id = ENV["GOOGLE_SHEET_ID"]
  end

  def append_withdrawal_reason(user)
    values = [
      [
        user.id,
        user.email,
        user.withdrawal_reason,
        Time.current.strftime("%Y-%m-%d %H:%M:%S")
      ]
    ]

    value_range = Sheets::ValueRange.new(values: values)
    @service.append_spreadsheet_value(
      @spreadsheet_id,
      "退会理由!A:D",
      value_range,
      value_input_option: "RAW"
    )
  end

  private

  def authorize
    scopes = [ "https://www.googleapis.com/auth/spreadsheets" ]
    json_content = ENV["GOOGLE_SERVICE_ACCOUNT_JSON"]
    raise "Google Service Account JSON not set in environment" unless json_content.present?

    Tempfile.create([ "service-account", ".json" ]) do |file|
      file.write(json_content)
      file.flush

      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(file.path),
        scope: scopes
      )
      authorizer.fetch_access_token!
      authorizer
    end
  end
end
