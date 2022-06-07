Pod::Spec.new do |spec|
  spec.name         = "MZRefresh"
  spec.version      = "0.0.4"
  spec.summary      = "Swift下拉刷新、上拉加载组件，简单易用，适用于UIScrollView、UITableView、UICollectionView等继承于UIScrollView的组件。"
  spec.homepage     = "https://github.com/1691665955/MZRefresh"
  spec.authors         = { 'MZ' => '1691665955@qq.com' }
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.source = { :git => "https://github.com/1691665955/MZRefresh.git", :tag => spec.version}
  spec.platform     = :ios, "9.0"
  spec.swift_version = '5.0'
  spec.source_files  = "MZRefresh/MZRefresh/*"
  spec.resource_bundles = {
    'MZRefresh' => ['MZRefresh/MZRefresh/Resources/*']
  }
  spec.dependency 'NVActivityIndicatorView'
end
