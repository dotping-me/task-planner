import 'package:flutter/material.dart';
import 'package:taskplanner/model/category.dart';
import 'package:taskplanner/screens/category_page.dart';

class Breadcrumbs extends StatelessWidget {
    final List<Category> trail;
    final BuildContext parentContext;

    const Breadcrumbs({
        super.key,
        required this.trail,
        required this.parentContext,
    });

    // Basically recursive navigation
    void _goToCategory(Category? category) {
        Navigator.push(
            parentContext,
            MaterialPageRoute(builder: (_) => CategoryPage(category: category)),
        );
    }

    @override
    Widget build(BuildContext context) {
        return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            
            child: Row(
                children: [
                    GestureDetector(
                        onTap: () => _goToCategory(null),
                        
                        child: const Text(
                            "Home",
                            style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                    ),

                    ...trail.map((cat) => Row(
                        children: [
                            const Text(" / "),
                            GestureDetector(
                                onTap: () => _goToCategory(cat),
                                
                                child: Text(
                                    cat.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                            ),
                        ],
                    ),),
                ],
            ),
        );
    }
}