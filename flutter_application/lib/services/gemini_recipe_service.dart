import 'package:google_generative_ai/google_generative_ai.dart';
import '/database/database_helper.dart'; // Güncel DatabaseHelper'ı buraya import et

class GeminiRecipeService {
  final String apiKey =
      "AIzaSyBfJAn7qJ_gKyLR4xBvTguQzY7nb_GtLjM"; // Replace with your API Key
  late GenerativeModel model;

  GeminiRecipeService() {
    model = GenerativeModel(
      model: "gemini-1.5-flash", // Ensure you use the correct model
      apiKey: apiKey,
    );
  }

  // Function to get ingredients from the inventory database
  Future<List<String>> getIngredientsFromDatabase() async {
    // Fetch inventory items from the new database
    final inventory = await DatabaseHelper().getInventory();

    // Extract food names from the inventory and return them
    return inventory.map((item) => item['food_name'] as String).toList();
  }

  // Function to generate a recipe from the ingredients
  Future<String> generateRecipe(List<String> ingredients) async {
    if (ingredients.isEmpty) {
      return "No ingredients found in the database.";
    }

    // Create the prompt for the Gemini model
    String prompt = "Generate a recipe using the following ingredients: "
        "${ingredients.join(', ')}. The recipe should include the ingredients and detailed steps.";

    try {
      // Generate the recipe using Gemini
      final responses = model.generateContentStream([
        Content.multi([TextPart(prompt)])
      ]);

      String aiResponse = '';
      await for (final response in responses) {
        aiResponse += response.text ?? ''; // Append each response's text
      }

      // If there's no response text, return a default message
      if (aiResponse.isEmpty) {
        return "No recipe generated. Please try again.";
      }

      return aiResponse;
    } catch (e) {
      return "Error generating recipe: $e";
    }
  }
}
