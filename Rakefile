require "rubygems/version"
require "rake/clean"
require "date"
require 'time'
require "json"
require "open3"

# Application info
APP_NAME = "MyPlayground"
SDK = "iphoneos"
WORKSPACE = File.expand_path("#{APP_NAME}.xcworkspace")
SCHEME = "MyPlayground"
INFO_PLIST = File.expand_path("#{APP_NAME}/Info.plist")

# Code signing
CODE_SIGN_IDENTITY_APPSTORE = "iPhone Distribution: TAKAYOSHI KOSHIDA (C59MXB37VX)";
CODE_SIGN_IDENTITY_INHOUSE = "iPhone Distribution: TAKAYOSHI KOSHIDA (C59MXB37VX)";
PROFILE_APPSTORE = "??.mobileprovision"
PROFILE_ADHOC = "test1.mobileprovision"
PROFILE_INHOUSE = "??.mobileprovision"
PROFILE_NAME_ADHOC = "test1"
PROFILE_NAME_INHOUSE = "?? Beta"
PROFILE_DIR = "$HOME/Library/MobileDevice/Provisioning Profiles"
KEYCHAIN_NAME = "ios-build.keychain"

# Build paths
BUILD_DIR = File.expand_path("build")
APP_FILE = File.expand_path("#{BUILD_DIR}/#{APP_NAME}.app")
ARCHIVE_FILE = File.expand_path("#{BUILD_DIR}/#{APP_NAME}.xcarchive")
ARCHIVE_ZIP_FILE = File.expand_path("#{BUILD_DIR}/#{APP_NAME}.xcarchive.zip")
IPA_FILE = File.expand_path("#{BUILD_DIR}/#{APP_NAME}.ipa")
DSYM_FILE = File.expand_path("#{BUILD_DIR}/#{APP_NAME}.app.dSYM")
DSYM_ZIP_FILE = File.expand_path("#{BUILD_DIR}/#{APP_NAME}.app.dSYM.zip")

# Test info
DESTINATIONS = [
                "name=iPad 2,OS=7.0.3",
                "name=iPad 2,OS=7.1",
                "name=iPad 2,OS=8.0",
                "name=iPad Air,OS=7.0.3",
                "name=iPad Air,OS=7.1",
                "name=iPad Air,OS=8.0",
                "name=iPad Retina,OS=7.0.3",
                "name=iPad Retina,OS=7.1",
                "name=iPad Retina,OS=8.0",
                "name=Resizable iPad,OS=8.0",
               ]

# Crittercism info
APP_ID = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
API_KEY = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Crashlytics info
# @@@

# TestFlight info
API_TOKEN = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
TEAM_TOKEN = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# DeployGate info

CLEAN.include(BUILD_DIR)
CLOBBER.include(BUILD_DIR)

task :default => [:build]

desc "Setting up a development environment"
task :setup do
  sh "bundle install"
  sh "pod install"
end

desc "Test application"
task test: ["test:release"]

namespace :test do
  task :release do
    test(configuration: "Release")
  end

  task :debug do
    test(configuration: "Debug")
  end

  task :adhoc do
    test(configuration: "AdHoc")
  end
end

def test(configuration: "Release")
  #options = build_options(sdk: "iphonesimulator8.1", configuration: configuration)
  options = build_options(sdk: "iphonesimulator8.1", configuration: configuration, workspace: WORKSPACE, scheme: SCHEME)
  # options << DESTINATIONS.map { |destination| %[-destination "#{destination}"] }.join(" ")
  #sh %[xcodebuild #{options} GCC_SYMBOLS_PRIVATE_EXTERN="NO" test | xcpretty -c; exit ${PIPESTATUS[0]}]
  sh %[xctool #{options} test | xcpretty -c; exit ${PIPESTATUS[0]}]
end

desc "Build application (Release)"
task build: ["build:release"]

namespace :build do
  desc "Build application (Release)"
  task :release do
    build
  end

  desc "Build application (AdHoc)"
  task :adhoc do
    build(configuration: "AdHoc")
  end
end

def build(configuration: "Release")
  options = build_options(configuration: configuration)
  settings = build_settings(configuration: configuration)
  sh %[xcodebuild #{options} #{settings} build | xcpretty -c; exit ${PIPESTATUS[0]}]
end

desc "Build artifacts (.xcarchive, ipa) (Release)"
task archive: ["archive:release"]

namespace :archive do
  desc "Build artifacts (.xcarchive, ipa) (Release)"
  task :release do
    archive
  end

  desc "Build artifacts (.xcarchive, ipa) (AdHoc)"
  task :adhoc do
    archive(configuration: "AdHoc")
  end
end

def archive(configuration: "Release")
  build_xcarchive(configuration: configuration)
  clean_ipa
  export_ipa(configuration: configuration)
end

def build_xcarchive(configuration: "Release")
  options = build_options(configuration: configuration)
  settings = build_settings(configuration: configuration)

  sh %[xcodebuild #{options} #{settings} archive -archivePath #{ARCHIVE_FILE} | xcpretty -c; exit ${PIPESTATUS[0]}]
end

def clean_ipa
  system "rm -f #{IPA_FILE}"
end

def export_ipa(configuration: "Release")
  sh %[xcodebuild -exportArchive #{export_options(configuration: configuration)} | xcpretty -c; exit ${PIPESTATUS[0]}]
end

def export_options(configuration: "Release")
  options = {
    exportFormat: "IPA",
    archivePath: ARCHIVE_FILE,
    exportPath: IPA_FILE,
    #exportProvisioningProfile: configuration == "Release" ? PROFILE_NAME_ADHOC : PROFILE_NAME_INHOUSE,
    exportProvisioningProfile: PROFILE_NAME_ADHOC,
  }
  join_options(options: options, prefix: "-", separator: " ")
end

def resign_ipa
  sh %[unzip -o #{IPA_FILE} -d build 1>/dev/null]
  sh %[rm -rf #{BUILD_DIR}/Payload/#{APP_NAME}.app/_CodeSignature/]
  sh %[cp #{PROFILE_ADHOC} #{BUILD_DIR}/Payload/#{APP_NAME}.app/embedded.mobileprovision]
  sh %[codesign --verify --force --sign "#{CODE_SIGN_IDENTITY_APPSTORE}" --resource-rules #{BUILD_DIR}/Payload/#{APP_NAME}.app/ResourceRules.plist #{BUILD_DIR}/Payload/#{APP_NAME}.app]
  sh %[(cd #{BUILD_DIR}; zip -ryq #{APP_NAME}.ipa Payload)]
end

def build_options(configuration: "Release", **others)
  options = {
    sdk: SDK,
    workspace: WORKSPACE,
    scheme: SCHEME,
    configuration: configuration,
  }.merge others
  join_options(options: options, prefix: "-", separator: " ")
end

def build_settings(configuration: "Release")
  code_sign_identity = configuration == "Release" ? CODE_SIGN_IDENTITY_APPSTORE : CODE_SIGN_IDENTITY_INHOUSE
  settings = {
    CONFIGURATION_BUILD_DIR: BUILD_DIR,
    CONFIGURATION_TEMP_DIR: "#{BUILD_DIR}/temp",
    CODE_SIGN_IDENTITY: code_sign_identity,
  }
  settings = join_options(options: settings, prefix: "", separator: "=")
end

desc "Upload IPA file to TestFlight (Release)"
task distribute: ["distribute:release"]

namespace :distribute do
  desc "Upload IPA file to TestFlight (Release)"
  task :release => ["archive:release"] do
    distribute
  end

  desc "Upload IPA file to TestFlight (AdHoc)"
  task :adhoc => ["version:update_build_version", "archive:adhoc"] do
    distribute
  end
end

def distribute
  #crittercism
  #testflight
  crashlytics
  deploygate
end

def crittercism
  options = {
    dsym: "@#{DSYM_ZIP_FILE}",
    key: API_KEY,
  }
  upload_form("https://api.crittercism.com/api_beta/dsym/#{APP_ID}", options)
end

def crashlytics
  #sh %[./Fabric.framework/run a1fd46856328894a8c65cc83637b8ea28938ed04 e2a0eb423ada3911b4eaa02a0ae857ca08eac7961b978ece5dfd349fe0e05a35]
end

def testflight
  pr_number = ENV["TRAVIS_PULL_REQUEST"]
  branch_name = ENV["TRAVIS_BRANCH"]

  release_date = DateTime.now.strftime("%Y/%m/%d %H:%M:%S")
  build_version = InfoPlist.marketing_and_build_version
  repo_url = "https://github.com/ubiregiinc/ubiregi-client"

  release_notes = "Build: #{build_version}\nUploaded: #{release_date}\n"

  if pull_request?
    release_notes << "Branch: #{repo_url}/commits/#{branch_name}\n"
    release_notes << "Pull Request: #{repo_url}/pull/#{pr_number}\n"
    release_notes << %x[git log --date=short --pretty=format:"* %h - %s (%cd) <%an>" --no-merges #{branch_name}..]
  else
    commit_hash = %x[git rev-parse HEAD].strip
    release_notes << "Branch: #{repo_url}/commits/#{branch_name}\n"
    if branch_name == "master"
      release_notes << %x[git log --date=short --pretty=format:"* %h - %s (%cd) <%an>" --no-merges $(git describe --abbrev=0 --tags)..]
    else
      release_notes << %x[git log --date=short --pretty=format:"* %h - %s (%cd) <%an>" --no-merges]
    end
  end

  options = {
    file: "@#{IPA_FILE}",
    api_token: API_TOKEN,
    team_token: TEAM_TOKEN,
    notify: true,
    replace: true,
    distribution_lists: pull_request? ? "Dev" : "Internal",
    notes: release_notes,
  }
  upload_form("http://testflightapp.com/api/builds.json", options)
end

def deploygate
  pr_number = ENV["TRAVIS_PULL_REQUEST"]
  branch_name = ENV["TRAVIS_BRANCH"]

  release_date = DateTime.now.strftime("%Y/%m/%d %H:%M:%S")
  build_version = InfoPlist.marketing_and_build_version
  repo_url = "https://github.com/tkoshida/MyPlayground"

  release_notes = "Build: #{build_version}\nUploaded: #{release_date}\n"

  if pull_request?
    release_notes << "Branch: #{repo_url}/commits/#{branch_name}\n"
    release_notes << "Pull Request: #{repo_url}/pull/#{pr_number}\n"
    release_notes << %x[git log --date=short --pretty=format:"* %h - %s (%cd) <%an>" --no-merges #{branch_name}..]
  else
    commit_hash = %x[git rev-parse HEAD].strip
    release_notes << "Branch: #{repo_url}/commits/#{branch_name}\n"
    if branch_name == "master"
      release_notes << %x[git log --date=short --pretty=format:"* %h - %s (%cd) <%an>" --no-merges $(git describe --abbrev=0 --tags)..]
    else
      release_notes << %x[git log --date=short --pretty=format:"* %h - %s (%cd) <%an>" --no-merges]
    end
  end

  token = ENV["DEPLOYGATE_TOKEN"]
  options = {
    file: "@#{IPA_FILE}",
    token: token,
    message: release_notes
  }
  upload_form("https://deploygate.com/api/users/#{ENV['DEPLOYGATE_USER']}/apps", options)
end

def upload_form(url, options = {})
  curl_options = ["curl", "-sSf", "-w", "%{http_code} %{url_effective}\\n", "#{url}"]
  form_fields = options.flat_map { |k, v| ["-F", "#{k}=#{v}"] }
  output_options = ["-o", "/dev/null"]
  sh *(curl_options + form_fields + output_options)
end

namespace :profile do
  desc "Download provisioning profiles from Apple Developer Center"
  task :download do
    profile_download("xxxxxxx@example.com", "xxxxxxxxxxxxxxxxxx")
  end

  task :install do
    profile_install
  end
end

def profile_download(user, passowrd)
  system "ios profiles:download:all -u #{user} -p #{password} --type distribution"
end

def profile_install
  sh %[mkdir -p "#{PROFILE_DIR}"]
  #sh %[cp "#{PROFILE_INHOUSE}" "#{PROFILE_DIR}"]
  sh %[cp "#{PROFILE_ADHOC}" "#{PROFILE_DIR}"]
end

namespace :certificate do
  task :add do
    add_certificates
  end

  task :remove do
    remove_certificates
  end
end

def add_certificates
  passphrase = "test1"

  sh "security create-keychain -p travis #{KEYCHAIN_NAME}"
  sh "security import ./certificates/AppleWWDRCA.cer -k #{KEYCHAIN_NAME} -T /usr/bin/codesign"
  #sh "security import ./certificates/appstore.cer -k #{KEYCHAIN_NAME} -T /usr/bin/codesign"
  #sh "security import ./certificates/appstore.p12 -k #{KEYCHAIN_NAME} -P #{passphrase} -T /usr/bin/codesign"
  #sh "security import ./certificates/inhouse.cer -k #{KEYCHAIN_NAME} -T /usr/bin/codesign"
  #sh "security import ./certificates/inhouse.p12 -k #{KEYCHAIN_NAME} -P #{passphrase} -T /usr/bin/codesign"
  sh "security import ./certificates/dist.cer -k #{KEYCHAIN_NAME} -T /usr/bin/codesign"
  sh "security import ./certificates/dist.p12 -k #{KEYCHAIN_NAME} -P #{passphrase} -T /usr/bin/codesign"
  sh "security default-keychain -s #{KEYCHAIN_NAME}"
end

def remove_certificates
  sh "security delete-keychain #{KEYCHAIN_NAME}"
end

def pull_request?
  pr_number = ENV["TRAVIS_PULL_REQUEST"]
  pr_number != nil && !pr_number.empty? && pr_number != "false"
end

def join_options(options: {}, prefix: "", separator: "")
  options.map { |k, v| %(#{prefix}#{k}#{separator}"#{v}") }.join(" ")
end

namespace :version do
  module InfoPlist
    extend self

    def [](key)
      output = %x[/usr/libexec/PlistBuddy -c "Print #{key}" #{INFO_PLIST}].strip
      raise "The key `#{key}' does not exist in `#{INFO_PLIST}'." if output.include?('Does Not Exist')
      output
    end

    def set(key, value, file = "#{INFO_PLIST}")
      %x[/usr/libexec/PlistBuddy -c 'Set :#{key} "#{value}"' '#{file}'].strip
    end
    def []=(key, value)
      set(key, value)
    end

    def build_version
      self['CFBundleVersion']
    end
    def build_version=(revision)
      self['CFBundleVersion'] = revision
    end

    def marketing_version
      self['CFBundleShortVersionString']
    end
    def marketing_version=(version)
      self['CFBundleShortVersionString'] = version
    end

    def bump_marketing_version_segment(segment_index)
      segments = Gem::Version.new(marketing_version).segments
      segments[segment_index] = segments[segment_index].to_i + 1
      (segment_index+1..segments.size-1).each { |i| segments[i] = 0 }
      version = segments.map(&:to_i).join('.')
      puts "Setting marketing version to: #{version}"
      self.marketing_version = version
      system("git commit #{INFO_PLIST} -m 'Bump to #{marketing_and_build_version}'")
    end

    def marketing_and_build_version
      "#{marketing_version} (#{build_version})"
    end

    def update_build_number
      build_number = %x[git rev-list HEAD | wc -l | tr -d " "].strip.to_i
      self.build_version = (build_number+1).to_s
    end

    def update_build_version
      rev = ""
      pr_number = ENV["TRAVIS_PULL_REQUEST"]
      if pull_request?
        rev << %x[git rev-parse --short HEAD^2].strip
        rev << " ##{pr_number}"
      else
        rev << %x[git rev-parse --short HEAD].strip
      end

      puts "Setting build version to: #{rev}"

      InfoPlist.build_version = rev
    end
  end

  desc "Print the current version"
  task :current do
    puts InfoPlist.marketing_and_build_version
  end

  desc "Sets build version to last git commit (happens on each build)"
  task :update_build_version do
    InfoPlist.update_build_version
  end

  desc "Sets build number to last git commit count (happens on each build)"
  task :update_build_number do
    InfoPlist.update_build_number
  end

  namespace :bump do
    desc "Bump patch version (0.0.X)"
    task :patch do
      InfoPlist.update_build_number
      InfoPlist.bump_marketing_version_segment(2)
    end

    desc "Bump minor version (0.X.0)"
    task :minor do
      InfoPlist.update_build_number
      InfoPlist.bump_marketing_version_segment(1)
    end

    desc "Bump major version (X.0.0)"
    task :major do
      InfoPlist.update_build_number
      InfoPlist.bump_marketing_version_segment(0)
    end
  end
end

desc "Print the current version"
task :version => 'version:current'
