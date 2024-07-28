import 'package:shadcn_flutter/shadcn_flutter.dart';

class TreeExample1 extends StatefulWidget {
  const TreeExample1({super.key});

  @override
  State<TreeExample1> createState() => _TreeExample1State();
}

class _TreeExample1State extends State<TreeExample1> {
  bool expandIcon = false;
  bool usePath = true;
  List<TreeNode<String>> treeItems = [
    TreeItem(
      data: 'Apple',
      expanded: true,
      children: [
        TreeItem(data: 'Red Apple', children: [
          TreeItem(data: 'Red Apple 1'),
          TreeItem(data: 'Red Apple 2'),
        ]),
        TreeItem(data: 'Green Apple'),
      ],
    ),
    TreeItem(
      data: 'Banana',
      children: [
        TreeItem(data: 'Yellow Banana'),
        TreeItem(data: 'Green Banana', children: [
          TreeItem(data: 'Green Banana 1'),
          TreeItem(data: 'Green Banana 2'),
          TreeItem(data: 'Green Banana 3'),
        ]),
      ],
    ),
    TreeItem(
      data: 'Cherry',
      children: [
        TreeItem(data: 'Red Cherry'),
        TreeItem(data: 'Green Cherry'),
      ],
    ),
    TreeItem(
      data: 'Date',
    ),
    // Tree Root acts as a parent node with no data,
    // it will flatten the children into the parent node
    TreeRoot(
      children: [
        TreeItem(
          data: 'Elderberry',
          children: [
            TreeItem(data: 'Black Elderberry'),
            TreeItem(data: 'Red Elderberry'),
          ],
        ),
        TreeItem(
          data: 'Fig',
          children: [
            TreeItem(data: 'Green Fig'),
            TreeItem(data: 'Purple Fig'),
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedContainer(
          child: SizedBox(
            height: 300,
            width: 250,
            child: TreeView(
              expandIcon: expandIcon,
              shrinkWrap: true,
              nodes: treeItems,
              branchLine: usePath ? BranchLine.path : BranchLine.line,
              builder: (context, node) {
                return TreeItemView(
                  onPressed: () {},
                  trailing: node.leaf
                      ? Container(
                          width: 16,
                          height: 16,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
                        )
                      : null,
                  leading: node.leaf
                      ? const Icon(BootstrapIcons.fileImage)
                      : Icon(node.expanded
                          ? BootstrapIcons.folder2Open
                          : BootstrapIcons.folder2),
                  onExpand: (expanded) {
                    if (expanded) {
                      setState(() {
                        treeItems = treeItems.expandNode(node);
                      });
                    } else {
                      setState(() {
                        treeItems = treeItems.collapseNode(node);
                      });
                    }
                  },
                  child: Text(node.data),
                );
              },
            ),
          ),
        ),
        gap(16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(
              onPressed: () {
                setState(() {
                  treeItems = treeItems.expandAll();
                });
              },
              child: Text('Expand All'),
            ),
            gap(8),
            PrimaryButton(
              onPressed: () {
                setState(() {
                  treeItems = treeItems.collapseAll();
                });
              },
              child: Text('Collapse All'),
            ),
          ],
        ),
        gap(8),
        Checkbox(
          state: expandIcon ? CheckboxState.checked : CheckboxState.unchecked,
          onChanged: (value) {
            setState(() {
              expandIcon = value == CheckboxState.checked;
            });
          },
          trailing: const Text('Expand Icon'),
        ),
        gap(8),
        Checkbox(
          state: usePath ? CheckboxState.checked : CheckboxState.unchecked,
          onChanged: (value) {
            setState(() {
              usePath = value == CheckboxState.checked;
            });
          },
          trailing: const Text('Use Path Branch Line'),
        ),
      ],
    );
  }
}
