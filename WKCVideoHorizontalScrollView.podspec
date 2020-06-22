Pod::Spec.new do |s|
s.name         = "WKCVideoHorizontalScrollView"
s.version      = "1.8.8"
s.summary      = "图片和视频混合使用的banner"
s.homepage     = "https://github.com/WKCLoveYang/WKCVideoHorizontalScrollView.git"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author             = { "WKCLoveYang" => "wkcloveyang@gmail.com" }
s.platform     = :ios, "11.0"
s.source       = { :git => "https://github.com/WKCLoveYang/WKCVideoHorizontalScrollView.git", :tag => "1.8.8" }
s.source_files  = "WKCVideoHorizontalScrollView/**/*.swift"
s.requires_arc = true
s.swift_version = "5.0"
s.dependency "iCarousel"

end
