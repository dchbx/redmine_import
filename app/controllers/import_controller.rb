class ImportController < ApplicationController
  unloadable

  def index
  end

  def run
    require 'open-uri'
    require 'curb'
    require 'json'

    redmine_token=""
    redmine_baseurl=""
    fileurl=""

    ## Download the file from the URL
    open('omniplan.csv', 'wb') do |file|
      file << open(fileurl).read
    end

    ## open the CSV and read it into a var
    @changes = {}
    fileLines = CSV.parse(File.read('omniplan.csv').encode('UTF-8', :invalid => :replace, :undef => :replace))
    fileLines.each do |omniplanTicket|
      issues = Issue.where('subject LIKE ?',omniplanTicket[1])
      if issues.count() == 1
        redmineIssueId = issues.first.id
        @changes[omniplanTicket[0]] = redmineIssueId
        http = Curl::Easy.http_put("#{redmine_baseurl}/issues/#{redmineIssueId}.json",{:issue => {
          :start_date => Date.strptime(omniplanTicket[2],"%m/%d/%y"),
          :due_date => Date.strptime(omniplanTicket[3],"%m/%d/%y"),
          :custom_fields => [
            :value => omniplanTicket[0],
            :id => 22
          ],
          :notes => "OmniPlan Import"
        } }.to_json) do |http|
          http.headers['X-Redmine-API-Key'] = redmine_token
          http.headers['Content-Type'] = "application/json"
          http.ssl_verify_peer = false
          http.verbose = true
        end
      end
    end
  end

end
