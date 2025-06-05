import 'dart:convert';
import 'package:http/http.dart' as http;

class GrokMessage {
  final String role;
  final dynamic content;
  final List<Map<String, dynamic>>? toolCalls;
  final String? toolCallId;
  final String? name;

  GrokMessage({
    required this.role,
    this.content,
    this.toolCalls,
    this.toolCallId,
    this.name,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {'role': role};
    if (content != null) json['content'] = content;
    if (toolCalls != null) json['tool_calls'] = toolCalls;
    if (toolCallId != null) json['tool_call_id'] = toolCallId;
    if (name != null && role == 'tool') json['name'] = name;
    return json;
  }
}

class ChatService {
  final String _apiKey = 'YOUR GROK API';
  final String _apiUrl = 'https://api.x.ai/v1/chat/completions';
  final String _model = 'grok-3';
  // Python connection
  final String _backendBaseUrl = 'http://192.168.100.107';

  Future<String> sendMessage(
      String userText, {
        required void Function(bool isTyping) onTypingStateChanged,
      }) async {
    try {
      onTypingStateChanged(true);

      // System message
      final systemMsg = GrokMessage(
        role: "system",
        content: """
        You are a product recommendation assistant.  
Your goal is to recommend products depending on what the user asks. Your goal is to
Recommend something if the users says something you that is not clear just recommend multiple products from different genres and after you do that ask 
tell them you there are products with these categories. Always include a price of the products you recommend and display the Price in OMR not dollars Eg: OMR 19.999.
Conversions are not needed as all the products are priced in OMR and try to avoid saying to much, keep the message a bit condensed.
Whenever the user asks to find or evaluate products you MUST call the `search_products(filter, limit)` function to fetch real catalog data then use that data to 
form your conclusion. At the end of your response please add some extra categories that are similar to what the user has searched for initially.
        """,
      );
      final userMsg = GrokMessage(
        role: "user",
        content: userText,
      );

      // Search tool
      final searchTool = {
        "type": "function",
        "function": {
          "name": "search_products",
          "description": "Query the CSV with filters for products",
          "parameters": {
            "type": "object",
            "properties": {
              "filter": {
                "type": "string",
                "description": "Keywords for product search",
              },
              "limit": {
                "type": "integer",
                "description": "Limit products",
              },
            },
            "required": ["filter"],
          },
        },
      };

      final List<Map<String, dynamic>> initialMessages = [
        systemMsg.toJson(),
        userMsg.toJson(),
      ];

      Map<String, dynamic> requestBody = {
        "model": _model,
        "messages": initialMessages,
        "tools": [searchTool],
        "tool_choice": "auto",
      };

      http.Response response;
      Map<String, dynamic> responseBody;

      // First API call
      try {
        response = await http.post(
          Uri.parse(_apiUrl),
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        );
        if (response.statusCode != 200) {
          return "Error HTTP: ${response.statusCode}";
        }
        // Get Response from API
        responseBody = jsonDecode(response.body);
      }
      catch (e) {
        return "First call error";
      }

      final assistantMessageData = responseBody['choices'][0]['message'];
      final List<dynamic>? toolCallsData = assistantMessageData['tool_calls'];

      if (toolCallsData != null && toolCallsData.isNotEmpty) {
        final List<Map<String, dynamic>> toolCalls = toolCallsData.map((tc) => tc as Map<String, dynamic>).toList();

        final assistantResponseWithToolCallsMsg = GrokMessage(
          role: "assistant",
          content: assistantMessageData['content'],
          toolCalls: toolCalls,
        );

        List<GrokMessage> toolResultMessages = [];

        for (final toolCall in toolCalls) {
          if (toolCall['function']['name'] == "search_products") {
            // Arguments from Grok response
            final args = jsonDecode(toolCall['function']['arguments']) as Map<String, dynamic>;
            final filter = args["filter"] as String;
            final limit = args["limit"] as int? ?? 5;
            final String toolCallId = toolCall['id'] as String;
            dynamic responseData;

            // Perform Search
            try {
              final searchUrl = Uri.parse('$_backendBaseUrl/search');
              final backendResp = await http.post(
                searchUrl,
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({"filter": filter, "limit": limit}),
              );

              // Successful search
              if (backendResp.statusCode == 200) {
                responseData = jsonDecode(backendResp.body);
              } else {
                responseData = {
                  "error": "Backend error",
                  "statusCode": backendResp.statusCode,
                  "body": backendResp.body.substring(0, (backendResp.body.length > 200 ? 200 : backendResp.body.length))
                };
              }
            } catch (e) {
              responseData = {"error": e.toString()};
            }

            toolResultMessages.add(
              GrokMessage(
                role: "tool",
                toolCallId: toolCallId,
                name: toolCall['function']['name'] as String,
                content: jsonEncode(responseData),
              ),
            );
          } else {
            final String toolCallId = toolCall['id'] as String;
            toolResultMessages.add(
              GrokMessage(
                role: "tool",
                toolCallId: toolCallId,
                name: toolCall['function']['name'] as String,
                content: jsonEncode({"error ${toolCall['function']['name']}"}),
              ),
            );
          }
        }

        // Follow up message
        List<Map<String, dynamic>> messageFollowUp = [
          systemMsg.toJson(),
          userMsg.toJson(),
          assistantResponseWithToolCallsMsg.toJson(),
          ...toolResultMessages.map((m) => m.toJson()).toList(),
        ];
        requestBody = {
          "model": _model,
          "messages": messageFollowUp,
        };

        // Second API call
        try {
          response = await http.post(
            Uri.parse(_apiUrl),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          );

          if (response.statusCode != 200) {
            return "Second Call Error HTTP ${response.statusCode}).";
          }
          responseBody = jsonDecode(response.body);
        }
        catch (e) {
          return "Second Call Error";
        }
        // Final response
        return responseBody['choices'][0]['message']['content'] as String;

      } else {
        return assistantMessageData['content'] as String? ??
            "Error";
      }
    } catch (e) {
      return "Error";
    } finally {
      onTypingStateChanged(false);
    }
  }
}