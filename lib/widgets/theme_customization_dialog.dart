import 'package:flutter/material.dart';
import '../models/app_theme.dart';

/// Dialog for theme customization
class ThemeCustomizationDialog extends StatefulWidget {
  final AppTheme currentTheme;
  final Function(AppTheme) onThemeChanged;
  final bool isDarkMode;

  const ThemeCustomizationDialog({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  State<ThemeCustomizationDialog> createState() => _ThemeCustomizationDialogState();
}

class _ThemeCustomizationDialogState extends State<ThemeCustomizationDialog> {
  late String selectedPreset;
  late AppTheme workingTheme;

  @override
  void initState() {
    super.initState();
    selectedPreset = widget.currentTheme.id;
    workingTheme = widget.currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            AppBar(
              title: const Text('Theme Customization'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text('Preset Themes', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _buildPresetGrid(),
                  const SizedBox(height: 32),
                  Text('Custom Colors', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _buildColorPickers(),
                  const SizedBox(height: 32),
                  _buildPreviewSection(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      widget.onThemeChanged(workingTheme);
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Theme'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetGrid() {
    final presets = AppThemes.all;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: presets.length,
      itemBuilder: (context, index) {
        final preset = presets[index];
        final isSelected = selectedPreset == preset.id;
        final themeData = widget.isDarkMode ? preset.darkTheme : preset.lightTheme;
        return InkWell(
          onTap: () {
            setState(() {
              selectedPreset = preset.id;
              workingTheme = preset;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: themeData.primaryColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      preset.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                if (isSelected)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(Icons.check_circle, color: Colors.white),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorPickers() {
    final themeData = widget.isDarkMode ? workingTheme.darkTheme : workingTheme.lightTheme;
    return Column(
      children: [
        _buildColorRow('Primary', themeData.primaryColor, (color) {
          // Custom theme creation would go here
        }),
        const SizedBox(height: 12),
        _buildColorRow('Secondary', themeData.colorScheme.secondary, (color) {
          // Custom theme creation would go here
        }),
        const SizedBox(height: 12),
        Text(
          'Custom colors coming soon',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
      ],
    );
  }

  Widget _buildColorRow(String label, Color color, Function(Color) onColorChanged) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        InkWell(
          onTap: () => _showColorPicker(label, color, onColorChanged),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 120,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewSection() {
    final themeData = widget.isDarkMode ? workingTheme.darkTheme : workingTheme.lightTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preview', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: themeData.primaryColor),
                  child: const Text('Primary'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: themeData.colorScheme.secondary),
                  child: const Text('Secondary'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showColorPicker(String label, Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Pick $label Color'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Colors.primaries.map((color) {
              return InkWell(
                onTap: () {
                  onColorChanged(color);
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: currentColor == color ? Colors.white : Colors.transparent, width: 3),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))],
      ),
    );
  }
}
