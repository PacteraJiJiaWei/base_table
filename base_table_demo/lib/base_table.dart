import 'package:flutter/material.dart';

typedef BaseTableRowItem = Widget Function(BaseTableIndexPath indexPath);
typedef BaseTableRowCount = int Function(int section);
typedef BaseTableSectionItem = Widget Function(int section);
typedef BaseTableSectionSpread = bool Function(int section);
typedef BaseTableSectionFooter = Widget Function(int section);
typedef BaseTableHeaderItem = Widget Function();
typedef BaseTableFooterItem = Widget Function();
typedef BaseTableBuildContext = Function(BuildContext context);
typedef BaseTableSectionItemType = BaseTableSectionType Function(int section);
typedef BaseTableBuildGroupMargin = BaseTableGroupMargin Function(int section);

class BaseTable extends StatefulWidget {
  /// 设置当前控件高度，如果不传，默认父控件高度
  final double height;

  /// 设置当前控件宽度，如果不传，默认父控件宽度
  final double width;

  /// 设置当前table的背景颜色
  final Color color;

  /// 滑动控制器
  final ScrollController controller;

  /// 设置当前table的section是否自动展开收起(默认false)
  final bool autoSpread;

  /// 设置当前table的section的数量
  final int sectionCount;

  /// 设置当前section对应的row的数量
  final BaseTableRowCount rowCount;

  /// 设置当前row对应的视图
  final BaseTableRowItem row;

  /// 设置当前section_header对应的视图
  final BaseTableSectionItem sectionHeader;

  /// 设置当前section_footer对应的视图
  final BaseTableSectionFooter sectionFooter;

  /// 设置当前section的展开状态
  final BaseTableSectionSpread sectionSpread;

  /// 设置当前table的header对应的视图
  final BaseTableHeaderItem header;

  /// 设置当前table的footer对应的视图
  final BaseTableFooterItem footer;

  /// 设置当前table对应的buildContext(手动刷新时使用)
  final BaseTableBuildContext buildContext;

  /// 设置当前section的Type(normal, group)
  final BaseTableSectionItemType sectionType;

  /// 设置当前group模块上，下，左，右的间距
  final BaseTableBuildGroupMargin groupMargin;

  BaseTable({
    Key key,
    this.height,
    this.width,
    this.color = Colors.black12,
    this.controller,
    this.autoSpread,
    this.sectionCount = 1,
    this.rowCount,
    this.row,
    this.sectionHeader,
    this.sectionFooter,
    this.sectionSpread,
    this.header,
    this.footer,
    this.buildContext,
    this.sectionType,
    this.groupMargin,
  })  : assert(rowCount != null, '需要通过rowCount来设置当前section的row的数量，不能为空'),
        assert(autoSpread == null || sectionSpread == null, 'autoSpread属性与sectionSpread属性冲突，不能一起使用'),
        super(key: key);

  @override
  _BaseTableState createState() => _BaseTableState();

  /// 用来获取当前的state
  static _BaseTableState of(BuildContext context) {
    return context.findAncestorStateOfType<_BaseTableState>();
  }
}

class _BaseTableState extends State<BaseTable> {
  /// 记录坐标数组
  List<BaseTableIndexPath> indexPaths;

  /// 记录展开状态数组
  List<bool> isSpreads = List();

  /// 用于校验数组
  List<int> rows = List();

  /// 是否是内部自动展开
  bool spread = false;

  @override
  void initState() {
    super.initState();

    // 初始化rows数组
    compareReload();
    // 创建indexPath的数组
    setUpIndexPaths();
  }

  /// 手动刷新列表
  reload() {
    setState(() {
      compareReload();
      setUpIndexPaths();
    });
  }

  /// 判断是否需要整体刷新数据
  bool compareReload() {
    // 是否要刷新数据
    bool reload = false;
    // 是否要初始化数组
    bool initList = false;

    // 获取section的数量
    int sections = widget.sectionCount;
    if (rows.length != sections) {
      rows = List();
      initList = true;
    }
    reload = initList;

    for (int i = 0; i < sections; i++) {
      // 获取每个section对应的row的数量
      int rowNum = widget.rowCount(i);
      if (initList) {
        rows.add(rowNum);
      } else {
        if (rows[i] != rowNum) {
          rows[i] = rowNum;
          reload = true;
        }
      }
    }
    return reload;
  }

  /// 设置坐标数组
  setUpIndexPaths() {
    // 初始化展开列表数组/indexPaths数组
    if (!spread) {
      isSpreads = List();
      spread = false;
    }
    indexPaths = List();

    // 添加header
    if (widget.header != null) {
      BaseTableIndexPath sectionIndexPath = BaseTableIndexPath(section: 0, row: 0, type: BaseTableItemType.header);
      indexPaths.add(sectionIndexPath);
    }

    // 判断是否缓存了展开状态数据
    bool isNull = isSpreads.length == 0;

    for (int i = 0; i < rows.length; i++) {
      BaseTableSectionType type = widget.sectionType != null ? widget.sectionType(i) : BaseTableSectionType.normal;
      // 添加section_header对应的indexPath
      BaseTableIndexPath sectionIndexPath = BaseTableIndexPath(
          section: i,
          row: 0,
          type: type == BaseTableSectionType.group
              ? BaseTableItemType.group_section_header
              : BaseTableItemType.section_header);
      indexPaths.add(sectionIndexPath);

      // 获取当前section是否是展开状态,如果不展开，不添加对应的rowItems
      bool isSpread = widget.sectionSpread == null ? true : widget.sectionSpread(i);
      if (widget.autoSpread == true) isNull ? isSpreads.add(isSpread) : isSpread = isSpreads[i];

      if (isSpread == true) {
        for (int j = 0; j < rows[i]; j++) {
          // 添加row对应的indexPath
          BaseTableIndexPath rowIndexPath = BaseTableIndexPath(
            section: i,
            row: j,
            type: type == BaseTableSectionType.group ? BaseTableItemType.group_row : BaseTableItemType.row,
          );
          indexPaths.add(rowIndexPath);
        }
      }

      // 添加section_footer对应的indexPath
      BaseTableIndexPath rowIndexPath = BaseTableIndexPath(
        section: i,
        row: 1,
        type: type == BaseTableSectionType.group
            ? BaseTableItemType.group_section_footer
            : BaseTableItemType.section_footer,
      );
      indexPaths.add(rowIndexPath);
    }

    // 添加footer
    if (widget.footer != null) {
      BaseTableIndexPath sectionIndexPath = BaseTableIndexPath(section: 0, row: 0, type: BaseTableItemType.footer);
      indexPaths.add(sectionIndexPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果没有设置宽高,会自动填满
    double height = widget.height == null ? MediaQuery.of(context).size.height : widget.height;
    double width = widget.width == null ? MediaQuery.of(context).size.width : widget.width;

    if (compareReload()) {
      // 设置每个item对应的indexPath
      setUpIndexPaths();
    }

    return Builder(
      builder: (context) {
        // 将列表的context传递出去(手动刷新时使用)
        if (widget.buildContext != null) widget.buildContext(context);
        return Container(
          width: width,
          height: height,
          color: widget.color,
          child: ListView.builder(
            controller: widget.controller,
            itemCount: indexPaths.length,
            itemBuilder: (context, index) {
              // 获取到当前item对应的indexPath
              BaseTableIndexPath currentIndexPath = indexPaths[index];
              // 获取group的外间距
              BaseTableGroupMargin margin =
                  widget.groupMargin != null ? widget.groupMargin(currentIndexPath.section) : BaseTableGroupMargin();

              // 根据indexPath的row属性来判断section/row/header/footer
              switch (currentIndexPath.type) {

                // section_header
                case BaseTableItemType.section_header:
                  return GestureDetector(
                    onTap: () {
                      // 判断是否自动展开
                      if (widget.autoSpread != true) return;
                      // 判断展开记录状态
                      bool currentState = isSpreads[currentIndexPath.section];
                      // 修改对应展开状态
                      isSpreads[currentIndexPath.section] = !currentState;
                      spread = true;
                      setState(() {
                        // 重新生成坐标数组
                        setUpIndexPaths();
                      });
                    },
                    // 如果没有设置section对应的widget，默认SizedBox()占位
                    child: widget.sectionHeader == null ? SizedBox() : widget.sectionHeader(currentIndexPath.section),
                  );

                // section_footer
                case BaseTableItemType.section_footer:
                  return widget.sectionFooter == null ? SizedBox() : widget.sectionFooter(currentIndexPath.section);

                // header
                case BaseTableItemType.header:
                  return widget.header == null ? SizedBox() : widget.header();

                // footer
                case BaseTableItemType.footer:
                  return widget.footer == null ? SizedBox() : widget.footer();

                // 内嵌group的section_header
                case BaseTableItemType.group_section_header:
                  return Container(
                    color: Colors.transparent,
                    margin: EdgeInsets.only(
                      left: margin.left,
                      right: margin.right,
                      top: margin.top,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        // 判断是否自动展开
                        if (widget.autoSpread != true) return;
                        // 判断展开记录状态
                        bool currentState = isSpreads[currentIndexPath.section];
                        // 修改对应展开状态
                        isSpreads[currentIndexPath.section] = !currentState;
                        spread = true;
                        setState(() {
                          // 重新生成坐标数组
                          setUpIndexPaths();
                        });
                      },
                      // 如果没有设置section对应的widget，默认SizedBox()占位
                      child: widget.sectionHeader == null ? SizedBox() : widget.sectionHeader(currentIndexPath.section),
                    ),
                  );

                // 内嵌group的section_footer
                case BaseTableItemType.group_section_footer:
                  return Container(
                    color: Colors.transparent,
                    margin: EdgeInsets.only(
                      left: margin.left,
                      right: margin.right,
                      bottom: margin.bottom,
                    ),
                    child: widget.sectionFooter == null ? SizedBox() : widget.sectionFooter(currentIndexPath.section),
                  );

                // 内嵌group的row
                case BaseTableItemType.group_row:
                  return Container(
                    color: Colors.transparent,
                    margin: EdgeInsets.only(
                      left: margin.left,
                      right: margin.right,
                    ),
                    child: widget.row(currentIndexPath),
                  );

                // row
                case BaseTableItemType.row:
                  return widget.row(currentIndexPath);

                default:
                  return SizedBox();
              }
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.controller != null) widget.controller.dispose();
  }
}

/// 记录坐标类
class BaseTableIndexPath {
  /// 组
  int section;

  /// 行
  int row;

  /// 组/行高
  double height;

  /// item类型
  BaseTableItemType type;

  BaseTableIndexPath({
    Key key,
    this.section,
    this.row,
    this.height,
    this.type,
  });
}

/// item的type类型
enum BaseTableItemType {
  header,
  footer,
  section_header,
  section_footer,
  row,
  group_row,
  group_section_header,
  group_section_footer,
}

/// section的type类型
enum BaseTableSectionType {
  normal,
  group,
}

/// 记录group模式外间距
class BaseTableGroupMargin {
  /// 左间距
  double left;

  /// 右间距
  double right;

  /// 上间距
  double top;

  /// 下间距
  double bottom;

  BaseTableGroupMargin({
    Key key,
    this.left = 10.0,
    this.right = 10.0,
    this.top = 10.0,
    this.bottom = 10.0,
  });
}
