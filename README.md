# MZRefresh
Swift下拉刷新、上拉加载组件，简单易用，适用于UIScrollView、UITableView、UICollectionView等继承于UIScrollView的组件。

<div align=center>
<img src="4.gif" width="300px" /><view width="20px"></view><img src="5.gif" width="300px" />
</div>

#### 使用
这里使用UIScrollView为例

- 刷新组件
```
// 下拉刷新组件
// type         刷新动画类型
// color        刷新动画颜色
// showTime     是否显示上次刷新时间
// beginRefresh 刷新回调
MZRefreshNormalHeader(type: .lineSpinFadeLoader, color: .brown, showTime: true) {

}

// 上拉加载组件
// type         刷新动画类型
// color        刷新动画颜色
// beginRefresh 刷新回调
MZRefreshNormalFooter(type: .lineSpinFadeLoader, color: .brown) {
    
}

```

- 添加刷新组件
```
// 添加下拉刷新组件
scrollView.setRefreshHeader(MZRefreshNormalHeader(beginRefresh: {
    // 请求数据，请求到数据后记得停止刷新动画
    self?.loadNew()
}))
// 添加上拉加载组件
scrollView.setRefreshFooter(MZRefreshNormalFooter(beginRefresh: {
    // 请求数据，请求到数据后记得停止刷新动画
    self?.loadMore()
}))

func loadNew() {
    // 请求数据，刷新页面
    // 停止下拉刷新动画
    scrollView.stopHeaderRefreshing()
}

func loadMore(_ count: Int) {
    // 请求数据，刷新页面
    // 停止上拉加载动画
    scrollView.stopFooterRefreshing()
}
```

- 移除刷新组件
```
// 移除下拉刷新组件
scrollView.removeRefreshHeader()
// 移除上拉加载组件
scrollView.removeRefreshFooter()
```

- 手动刷新或加载更多
```
// 手动触发下拉刷新
// animated代表是否执行动画
self.scrollView.startHeaderRefreshing(animated: true)

// 手动触发上拉加载
// animated代表是否执行动画
self.scrollView.startFooterRefreshing(animated: true)
```

- 停止刷新动画
```
// 停止下拉刷新动画
scrollView.stopHeaderRefreshing()
// 停止上拉加载动画
scrollView.stopFooterRefreshing()
```


#### 动画类型
<div align=center>
<img src="1.gif" width="300px" /><view width="20px"></view><img src="2.gif" width="300px" /><img src="3.gif" width="300px" />
</div>
