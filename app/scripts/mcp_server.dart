#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  stdout.write(jsonEncode({
    'jsonrpc': '2.0',
    'id': 1,
    'result': {
      'protocolVersion': '2024-11-05',
      'capabilities': {'tools': {}, 'resources': {}, 'prompts': {}},
      'serverInfo': {'name': 'flutter-health-app', 'version': '1.0.0'}
    }
  }));
  stdout.writeln();
  stdout.flush();

  final input = StringBuffer();
  await for (final chunk in stdin.transform(utf8.decoder)) {
    input.write(chunk);
    final lines = input.toString().split('\n');
    input.clear();

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      try {
        final request = jsonDecode(line) as Map<String, dynamic>;
        final id = request['id'];
        final method = request['method'] as String?;

        if (method == 'initialize') {
          stdout.write(jsonEncode({
            'jsonrpc': '2.0',
            'id': id,
            'result': {
              'protocolVersion': '2024-11-05',
              'capabilities': {'tools': {}, 'resources': {}, 'prompts': {}},
              'serverInfo': {'name': 'flutter-health-app', 'version': '1.0.0'}
            }
          }));
          stdout.writeln();
        } else if (method == 'notifications/initialized') {
          // Client is ready
        } else if (method == 'tools/list') {
          stdout.write(jsonEncode({
            'jsonrpc': '2.0',
            'id': id,
            'result': {
              'tools': [
                {
                  'name': 'get_project_info',
                  'description':
                      'Get information about the Flutter health app project',
                  'inputSchema': {'type': 'object', 'properties': {}}
                },
                {
                  'name': 'list_features',
                  'description': 'List available features in the health app',
                  'inputSchema': {'type': 'object', 'properties': {}}
                },
                {
                  'name': 'get_project_structure',
                  'description': 'Get the project directory structure',
                  'inputSchema': {'type': 'object', 'properties': {}}
                },
                {
                  'name': 'analyze_flutter_code',
                  'description': 'Analyze Flutter code for best practices',
                  'inputSchema': {
                    'type': 'object',
                    'properties': {
                      'code': {
                        'type': 'string',
                        'description': 'The Flutter code to analyze'
                      }
                    },
                    'required': ['code']
                  }
                }
              ]
            }
          }));
          stdout.writeln();
        } else if (method == 'tools/call') {
          final params = request['params'] as Map<String, dynamic>;
          final toolName = params['name'] as String;
          final arguments = params['arguments'] as Map<String, dynamic>?;

          String result = '';
          bool isError = false;

          switch (toolName) {
            case 'get_project_info':
              result =
                  'Flutter Health Management App - A comprehensive health tracking application with nutrition, exercise, and health metrics monitoring.';
              break;
            case 'list_features':
              result =
                  'Features: Health tracking, Nutrition monitoring, Exercise logging, Medication reminders, AI-powered insights, Background sync, Google OAuth authentication';
              break;
            case 'get_project_structure':
              result =
                  'Project structure: app/lib/core (core functionality), app/lib/features (feature modules), app/lib/shared (shared components), backend/api (backend API), mock-server (development server)';
              break;
            case 'analyze_flutter_code':
              final code = arguments?['code'] as String? ?? '';
              if (code.isEmpty) {
                result = 'Please provide code to analyze';
                isError = true;
              } else {
                final issues = <String>[];
                if (code.contains('setState(()') && !code.contains('mounted')) {
                  issues.add(
                      'Consider checking mounted state before calling setState');
                }
                if (code.contains('async') && !code.contains('try')) {
                  issues.add(
                      'Consider adding error handling for async operations');
                }
                if (!code.contains('const') && code.contains('Widget')) {
                  issues.add(
                      'Consider using const constructors for widgets where possible');
                }
                result = issues.isEmpty
                    ? 'Code looks good!'
                    : 'Issues found: ${issues.join(", ")}';
              }
              break;
            default:
              result = 'Unknown tool: $toolName';
              isError = true;
          }

          stdout.write(jsonEncode({
            'jsonrpc': '2.0',
            'id': id,
            'result': {
              'content': [
                {'type': 'text', 'text': result}
              ]
            }
          }));
          stdout.writeln();
        }

        stdout.flush();
      } catch (e) {
        stderr.writeln('Error: $e');
      }
    }
  }
}
