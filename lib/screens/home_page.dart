import 'package:flutter/material.dart';
import 'category_page.dart';

class HomePage extends StatelessWidget {
    const HomePage({super.key});

    @override
    Widget build(BuildContext context) {
        return CategoryPage(category: null); // Root level
    }
}