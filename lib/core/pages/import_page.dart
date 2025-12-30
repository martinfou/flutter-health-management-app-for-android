import 'package:flutter/material.dart';
import 'package:health_app/core/constants/ui_constants.dart';
import 'package:health_app/core/utils/export_utils.dart';
import 'package:health_app/core/widgets/custom_button.dart';
import 'package:health_app/core/widgets/loading_indicator.dart';
import 'package:health_app/core/widgets/error_widget.dart' as core_error;
import 'package:health_app/core/errors/failures.dart';
// Note: file_picker package needs to be added to pubspec.yaml for file selection
// import 'package:file_picker/file_picker.dart';

/// Import page for restoring user data from backup
class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  bool _isImporting = false;
  bool _isValidating = false;
  String? _selectedFilePath;
  Failure? _importError;
  String? _validationMessage;

  Future<void> _pickFile() async {
    // TODO: Add file_picker package to pubspec.yaml for file selection
    // For now, show a message that file picker needs to be implemented
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'File picker requires file_picker package. '
          'Please add file_picker to pubspec.yaml dependencies.',
        ),
      ),
    );
    
    // Placeholder: In production, this would use FilePicker
    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['json'],
    //   withData: false,
    // );
    // 
    // if (result != null && result.files.single.path != null) {
    //   setState(() {
    //     _selectedFilePath = result.files.single.path!;
    //     _importError = null;
    //     _validationMessage = null;
    //   });
    //   
    //   // Validate file
    //   await _validateFile();
    // }
  }

  Future<void> _validateFile() async {
    if (_selectedFilePath == null) return;
    
    setState(() {
      _isValidating = true;
      _validationMessage = null;
    });
    
    final result = await ExportService.validateImportFile(_selectedFilePath!);
    
    result.fold(
      (failure) {
        setState(() {
          _isValidating = false;
          _validationMessage = failure.message;
        });
      },
      (message) {
        setState(() {
          _isValidating = false;
          _validationMessage = message;
        });
      },
    );
  }

  Future<void> _handleImport() async {
    if (_selectedFilePath == null) return;
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text(
          'This will import data from the selected file and replace your current data.\n\n'
          'It is recommended to export your current data first as a backup.\n\n'
          'Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CustomButton(
            label: 'Import',
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
      _isImporting = true;
      _importError = null;
    });

    final result = await ExportService.importAllData(_selectedFilePath!);

    result.fold(
      (failure) {
        setState(() {
          _isImporting = false;
          _importError = failure;
        });
      },
      (message) {
        setState(() {
          _isImporting = false;
        });

        // Show success dialog
        _showSuccessDialog(message);
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: UIConstants.spacingSm),
            Text('Import Successful'),
          ],
        ),
        content: Text(message),
        actions: [
          CustomButton(
            label: 'OK',
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Close import page
            },
            variant: ButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          'About Data Import',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingMd),
                    const Text(
                      'Import your health data from a previously exported JSON file. '
                      'This will replace your current data with the imported data.',
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                    Text(
                      'Note: It is recommended to export your current data first as a backup.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: UIConstants.spacingLg),

            // File picker button
            CustomButton(
              label: _selectedFilePath == null
                  ? 'Select Import File'
                  : 'Change File',
              onPressed: _pickFile,
              variant: ButtonVariant.secondary,
              icon: Icons.folder_open,
              width: double.infinity,
            ),

            if (_selectedFilePath != null) ...[
              const SizedBox(height: UIConstants.spacingMd),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected File',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: UIConstants.spacingSm),
                      Text(
                        _selectedFilePath!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (_isValidating) ...[
                        const SizedBox(height: UIConstants.spacingMd),
                        const LoadingIndicator(message: 'Validating file...'),
                      ] else if (_validationMessage != null) ...[
                        const SizedBox(height: UIConstants.spacingMd),
                        Row(
                          children: [
                            Icon(
                              _validationMessage!.contains('valid')
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: _validationMessage!.contains('valid')
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.error,
                              size: UIConstants.iconSizeMd,
                            ),
                            const SizedBox(width: UIConstants.spacingSm),
                            Expanded(
                              child: Text(
                                _validationMessage!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _validationMessage!.contains('valid')
                                          ? Colors.green
                                          : Theme.of(context).colorScheme.error,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: UIConstants.spacingLg),

            // Import button
            if (_isImporting)
              const LoadingIndicator(message: 'Importing data...')
            else if (_importError != null)
              core_error.ErrorWidget(
                message: _importError!.message,
                onRetry: _handleImport,
              )
            else
              CustomButton(
                label: 'Import Data',
                onPressed:
                    _selectedFilePath != null && _validationMessage?.contains('valid') == true
                        ? _handleImport
                        : null,
                variant: ButtonVariant.primary,
                icon: Icons.upload,
                width: double.infinity,
              ),
          ],
        ),
      ),
    );
  }
}

