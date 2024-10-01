# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'
install! 'cocoapods', :deterministic_uuids => false
source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

def shared_pods
    pod 'Alamofire', '4.9.1'
    pod 'SwiftyJSON', '5.0.0'
    pod 'PromiseKit', '6.13.1'
    pod 'Nuke', '7.5.2'
    pod 'Toucan', :git => 'https://github.com/sakiwei/Toucan.git', :branch => 'develop'
    pod 'SwiftMessages', '7.0.1'
    pod 'GoogleMaps', '3.8.0'
    pod 'GooglePlaces', '3.8.0'
    pod 'SwiftLint', '0.31.0'
    pod 'FSCalendar', '2.8.1'
    pod 'Amplitude-iOS', '4.10.0'
    pod 'Firebase', '6.15.0'
    pod 'Firebase/Analytics'
    pod 'Firebase/Crashlytics'
    pod 'Firebase/Messaging'
    pod 'Firebase/RemoteConfig'
    pod 'RealmSwift'
    pod 'Realm'
    pod 'VK-ios-sdk', '1.5.1'
    pod 'YandexMobileMetrica/Dynamic', '3.9.4'
    pod 'YandexMobileMetricaPush/Dynamic', '0.8.0'
    pod 'Fabric', '1.10.2'
    pod 'Crashlytics', '3.14.0'
    pod 'GoogleUtilities', '6.6.0'
    pod 'UIColor_Hex_Swift', '5.1.0'
    pod 'Branch', '0.33.1'
    pod 'PopupDialog', '1.0.0'
    pod 'DeckTransition', '2.2.0'
    pod 'Presentr', '1.3.2'
    pod 'SnapKit', '4.2.0'
    pod 'SkeletonView', '1.8.7'
    pod 'TagListView', '1.4.0'
    pod 'YandexMobileAds/Dynamic', '2.15.2'
    pod 'YoutubeKit', '0.5.0'
    pod 'Nuke-WebP-Plugin', '3.1.0'
    pod 'YandexMapsMobile', '4.2.2-full'
    pod 'Protobuf', '= 3.22.1'
end

target 'Moscow Seasons' do
    shared_pods
end

target 'Armenia Guide' do
    shared_pods
end

target 'Planetarium' do
    shared_pods
end

target 'Tretyakov' do
    shared_pods
end

target 'Marche Guide' do
    shared_pods
end

target 'Moscow Seasons TEST' do
    shared_pods
end

target 'Marche Guide TEST' do
    shared_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      config.build_settings["ONLY_ACTIVE_ARCH"] = "YES"
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
