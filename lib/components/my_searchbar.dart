import 'package:flutter/material.dart';

class MySearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const MySearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  _MySearchBarState createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.light
              ? Colors.white
              : Colors.grey[800],
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            // Search Icon
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(
                Icons.search,
                color: theme.brightness == Brightness.light
                    ? Colors.grey
                    : Colors.white,
              ),
            ),
            // Search TextField
            Expanded(
              flex: 1,
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                style: TextStyle(
                  fontSize: 16.0,
                  color: theme.brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    fontSize: 14.0,
                    color: theme.brightness == Brightness.light
                        ? Colors.grey
                        : Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 10.0,
                  ),
                ),
              ),
            ),
            // Clear button
            widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged('');
                    },
                    color: theme.brightness == Brightness.light
                        ? Colors.grey
                        : Colors.white,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
