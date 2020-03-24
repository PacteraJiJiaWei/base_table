import 'package:flutter/material.dart';

typedef BaseTableRowItem = Widget Function(BaseTableIndexPath indexPath);
typedef BaseTableRowCount = int Function(int section);
typedef BaseTableSectionItem = Widget Function(int section);
typedef BaseTableSectionSpread = bool Function(int section);
typedef BaseTableSectionFooter = Widget Function(int section);
typedef BaseTableHeaderItem = Widget Function();
typedef BaseTableFooterItem = Widget Function();
typedef BaseTableBuildContext = Function(BuildContext context);

/// 新增内嵌group
typedef BaseTableSectionTypes = BaseTableSectionType Function(int section);

class BaseTable extends StatefulWidget {
  /// 当前控件高度
  final double height;

  /// 当前控件宽度
  final double width;

  /// 背景颜色
  final Color color;

  /// 滑动控制器
  final ScrollController controller;

  /// section是否自动展开收起(默认false)
  final bool autoSpread;

  /// List的section的数量
  final int sectionCount;

  /// 当前section对应的row的数量
  final BaseTableRowCount rowCount;

  /// 当前row对应的item
  final BaseTableRowItem row;

  /// 当前section对应的item
  final BaseTableSectionItem sectionHeader;

  /// 当前section对应的footer
  final BaseTableSectionFooter sectionFooter;

  /// 当前section的展开状态(默认true)
  final BaseTableSectionSpread sectionSpread;

  /// header
  final BaseTableHeaderItem header;

  /// footer
  final BaseTableFooterItem footer;

  /// 当前buildContext(手动刷新时使用)
  final BaseTableBuildContext buildContext;

  /// 当前section的Type(normal, group)
  final BaseTableSectionTypes sectionTypes;

  final Color groupColor;

  final double groupMainMargin;

  final double groupCrossMargin;

  final double groupRadius;

  BaseTable({
    Key key,
    this.height,
    this.width,
    this.color = Colors.black12,
    this.controller,
    this.autoSpread = false,
    this.sectionCount = 1,
    this.rowCount,
    this.row,
    this.sectionHeader,
    this.sectionFooter,
    this.sectionSpread,
    this.header,
    this.footer,
    this.buildContext,
    this.sectionTypes,
    this.groupColor = Colors.white,
    this.groupMainMargin = 10.0,
    this.groupCrossMargin = 10.0,
    this.groupRadius = 5.0,
  })  : assert(rowCount != null, '需要通过rowCount来设置当前section的row的数量，不能为空'),
        super(key: key);

  @override
  _BaseTableState createState() => _BaseTableState();

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

  // 判断是否需要整体刷新数据
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
      BaseTableSectionType type = widget.sectionTypes != null ? widget.sectionTypes(i) : BaseTableSectionType.normal;
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
              // 根据indexPath的row属性来判断section/row/header/footer
              if (currentIndexPath.type == BaseTableItemType.section_header) {
                // section_header
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
              } else if (currentIndexPath.type == BaseTableItemType.section_footer) {
                // section_footer
                return widget.sectionFooter == null ? SizedBox() : widget.sectionFooter(currentIndexPath.section);
              } else if (currentIndexPath.type == BaseTableItemType.header) {
                // header
                return widget.header == null ? SizedBox() : widget.header();
              } else if (currentIndexPath.type == BaseTableItemType.footer) {
                // footer
                return widget.footer == null ? SizedBox() : widget.footer();
              } else if (currentIndexPath.type == BaseTableItemType.group_row) {
                // 内嵌group的row
                return Container(
                  color: widget.groupColor,
                  margin: EdgeInsets.only(
                    left: widget.groupCrossMargin,
                    right: widget.groupCrossMargin,
                  ),
                  child: widget.row(currentIndexPath),
                );
              } else if (currentIndexPath.type == BaseTableItemType.group_section_header) {
                // 内嵌group的section_header
                return Container(
                  margin: EdgeInsets.only(
                    left: widget.groupCrossMargin,
                    right: widget.groupCrossMargin,
                    top: widget.groupMainMargin,
                  ),
                  padding: EdgeInsets.only(top: widget.groupRadius),
                  decoration: BoxDecoration(
                    color: widget.groupColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(widget.groupRadius),
                      topRight: Radius.circular(widget.groupRadius),
                    ),
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
                    child: widget.sectionHeader == null
                        ? SizedBox(
                            height: widget.groupRadius,
                          )
                        : widget.sectionHeader(currentIndexPath.section),
                  ),
                );
              } else if (currentIndexPath.type == BaseTableItemType.group_section_footer) {
                // 内嵌group的section_footer
                return Container(
                  margin: EdgeInsets.only(
                    left: widget.groupCrossMargin,
                    right: widget.groupCrossMargin,
                    bottom: widget.groupMainMargin,
                  ),
                  padding: EdgeInsets.only(bottom: widget.groupRadius),
                  decoration: BoxDecoration(
                    color: widget.groupColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(widget.groupRadius),
                      bottomRight: Radius.circular(widget.groupRadius),
                    ),
                  ),
                  child: widget.sectionFooter == null ? SizedBox() : widget.sectionFooter(currentIndexPath.section),
                );
              } else {
                // row
                return widget.row(currentIndexPath);
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
