import 'dart:io';
import 'package:flutter/material.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/utils/export_utils.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/core/widgets/loading_indicator.dart';
import 'package:health_app/core/widgets/error_widget.dart' as core_error;
import 'package:health_app/core/errors/failures.dart';
import 'package:share_plus/share_plus.dart';

/// Export page for backing up user data
class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  bool _isExporting = false;
  String? _exportPath;
  Failure? _exportError;

  Future<void> _handleExport() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'This will export all your health data to a JSON file. '
          'The file will be saved to your device\'s Downloads folder, making it easy to find and import later.\n\n'
          'Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CustomButton(
            label: 'Export',
            onPressed: () => Navigator.of(context).pop(true),
            variant: ButtonVariant.primary,
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isExporting = true;
      _exportError = null;
      _exportPath = null;
    });

    final result = await ExportService.exportAllData();

    result.fold(
      (failure) {
        setState(() {
          _isExporting = false;
          _exportError = failure;
        });
      },
      (filePath) {
        setState(() {
          _isExporting = false;
          _exportPath = filePath;
        });

        // Show success dialog
        _showSuccessDialog(filePath);
      },
    );
  }

  Future<void> _shareFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final xFile = XFile(filePath);
        await Share.shareXFiles(
          [xFile],
          subject: 'Health App Data Export',
          text: 'My health data export from Health Tracker App',
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File not found. Please export again.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing file: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: UIConstants.spacingSm),
            Text('Export Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your data has been exported successfully.'),
            const SizedBox(height: UIConstants.spacingMd),
            Text(
              'File location:',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: UIConstants.spacingXs),
            SelectableText(
              filePath,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: UIConstants.spacingMd),
            const Text(
              'The file has been saved. You can share it to save to cloud storage (Dropbox, Google Drive, etc.) for safekeeping. When importing, use the file picker to select the file from your device or cloud storage.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          CustomButton(
            label: 'Share',
            onPressed: () {
              Navigator.of(context).pop();
              _shareFile(filePath);
            },
            variant: ButtonVariant.primary,
            icon: Icons.share,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Information section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: UIConstants.spacingSm),
                        Text(
                          'About Data Export',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingMd),
                    const Text(
                      'Export your health data to a JSON file for backup. '
                      'The exported file contains all your health metrics, '
                      'meals, exercises, medications, and other data.',
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    Text(
                      'The file will be saved to your device\'s Downloads folder (if accessible) or the app\'s storage directory. You can share the file to save it to cloud storage (Dropbox, Google Drive, etc.) for safekeeping.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingLg),

            // Export button
            if (_isExporting)
              const LoadingIndicator(message: 'Exporting data...')
            else if (_exportError != null)
              core_error.ErrorWidget(
                message: _exportError!.message,
                onRetry: _handleExport,
              )
            else
              CustomButton(
                label: 'Export Data',
                onPressed: _handleExport,
                variant: ButtonVariant.primary,
                icon: Icons.download,
                width: double.infinity,
              ),

            if (_exportPath != null) ...[
              const SizedBox(height: UIConstants.spacingLg),
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: UIConstants.spacingSm),
                          Text(
                            'Last Export',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: UIConstants.spacingSm),
                      Text(
                        _exportPath!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: UIConstants.spacingMd),
                      CustomButton(
                        label: 'Share File',
                        onPressed: () => _shareFile(_exportPath!),
                        variant: ButtonVariant.secondary,
                        icon: Icons.share,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

