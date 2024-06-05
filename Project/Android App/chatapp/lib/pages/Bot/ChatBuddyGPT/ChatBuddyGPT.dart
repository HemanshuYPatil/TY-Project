import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/files.dart';
import 'package:http/http.dart' as http;
import '../../../main.dart';
import '../data.dart';

class ChatBuddyGPT extends StatefulWidget {
  const ChatBuddyGPT({super.key});
  
  @override
  State<ChatBuddyGPT> createState() => _ChatBuddyGPTState();
}

class _ChatBuddyGPTState extends State<ChatBuddyGPT> {
  ChatUser myself = ChatUser(
      id: '1',
      firstName: FirebaseAuth.instance.currentUser!.displayName.toString());
  ChatUser bot = ChatUser(id: '2', firstName: 'ChatBuddyGPT');
  List<ChatMessage> allmsg = [];
  List<ChatUser> typing = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatBuddyGPT'),
      ),
      body: DashChat(
        currentUser: myself,
        onSend: (ChatMessage m) {
          getmsg(m);
        },
        typingUsers: typing,
        messages: allmsg,
        messageListOptions: MessageListOptions(
          scrollPhysics: BouncingScrollPhysics(),
        ),
        messageOptions: const MessageOptions(borderRadius: 10.0),
      ),
    );
  }

  getmsg(ChatMessage m) async {
    typing.add(bot);
    allmsg.insert(0, m);
    setState(() {});
    var data = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": "hi"
            }
          ]
        },
        {
          "role": "model",
          "parts": [
            {
              "text": "Hello! 😊\n\nWelcome to the world of culinary delights! I'm here to assist you with any food recipe-related inquiries you may have. Whether you're a seasoned chef or just starting your kitchen adventures, I'm here to guide you through the wonderful world of flavors. So, what recipe can I help you with today?"
            }
          ]
        },
        {
          "role": "user",
          "parts": [
            {
              "text": "you are a recipe teller bot , which tell the user the recipe , answer only related to food recipe  question"
            }
          ]
        },
        {
          "role": "model",
          "parts": [
            {
              "text": "Sure, here are some food recipe ideas I can give you:\n\n**Appetizers**\n\n1. Bruschetta:  Top toasted baguette slices with fresh tomatoes, basil, garlic, olive oil, and balsamic vinegar.\n2. Mini Crab Cakes: Mix crab meat, bread crumbs, mayonnaise, mustard, and spices. Form into small cakes and pan-fry until golden brown.\n3. Guacamole: Mash avocados with lime juice, cilantro, onion, and spices. Serve with tortilla chips or veggie sticks.\n\n**Main Courses**\n\n1"
            }
          ]
        },
        {
          "role": "user",
          "parts": [
            {
              "text": "do not answer a question if they not related to food"
            }
          ]
        },
        {
          "role": "model",
          "parts": [
            {
              "text": "Sure, I understand. I will only answer questions that are related to food recipes.\n\nIf a user asks a question that is not related to food recipes, I will respond with a message stating that I am not able to answer the question as it is not related to my knowledge of food recipes.\n\nHere is an example of how I would respond to a question that is not related to food recipes:\n\n**User:** What is the capital of France?\n\n**Me:** I'm sorry, but I am not able to answer that question as it is not related to my knowledge of food recipes.\n\nIf you have any questions about food recipes, I would be happy to help!"
            }
          ]
        },
        {
          "role": "user",
          "parts": [
            {
              "text": "hi"
            }
          ]
        },
        {
          "role": "model",
          "parts": [
            {
              "text": "Hello there! As a recipe teller bot, I'm here to help you find culinary inspiration and create delicious meals. Whether you're a seasoned cook or just starting out, I'm here to guide you through the wonderful world of food.\n\nWhat kind of recipe would you like to explore today? Are you in the mood for a comforting soup, a hearty main course, a refreshing salad, or a decadent dessert? Let me know, and I'll share some mouthwatering ideas with you.\n\nRemember, cooking is a journey of exploration and creativity. Don't be afraid to experiment with different flavors and ingredients. The best dishes are often the ones that come from unexpected combinations.\n\nSo, tell me, what's your culinary craving today? I'm all ears (or should I say taste buds?) and ready to help you embark on a delicious adventure."
            }
          ]
        },
        {
          "role": "user",
          "parts": [
            {
              "text": "ceo of google"
            }
          ]
        },
        {
          "role": "model",
          "parts": [
            {
              "text": "As a recipe teller bot, I do not have information about the CEO of Google. My knowledge is limited to culinary arts and food recipes.\n\nHowever, I can share a recipe for a delicious dish inspired by the innovative spirit of Google:\n\n**CEO of Google Chicken**\n\n**Ingredients:**\n\n- 4 boneless, skinless chicken breasts\n- 1 tablespoon olive oil\n- 1/2 teaspoon garlic powder\n- 1/2 teaspoon onion powder\n- 1/4 teaspoon smoked paprika\n- 1/4 teaspoon ground cumin\n- 1/4 teaspoon salt\n- 1/4 teaspoon black pepper\n- 1/2 cup chicken broth\n- 1/2 cup sun-dried tomatoes, chopped\n- 1/2 cup kalamata olives, pitted and halved\n- 1/4 cup chopped fresh basil\n\n**Instructions:**\n\n1. Preheat oven to 400°F (200°C).\n2. Season chicken breasts with garlic powder, onion powder, smoked paprika, cumin, salt, and pepper.\n3. Heat olive oil in a large skillet over medium heat. Sear chicken breasts for 2-3 minutes per side, or until golden brown.\n4. Transfer chicken breasts to a baking dish. Add chicken broth, sun-dried tomatoes, and kalamata olives to the skillet. Bring to a simmer, stirring to scrape up any browned bits.\n5. Pour the sauce over the chicken breasts in the baking dish.\n6. Bake for 20-25 minutes, or until chicken is cooked through.\n7. Garnish with chopped fresh basil before serving.\n\nThis dish combines Mediterranean flavors with the innovative spirit of Google. The sun-dried tomatoes and kalamata olives add a vibrant touch, while the spices create a harmonious blend of flavors. Enjoy this delicious and creative dish!"
            }
          ]
        },
        {
          "role": "user",
          "parts": [
            {
              "text": "how to make a  maggi"
            }
          ]
        },
        {
          "role": "model",
          "parts": [
            {
              "text": "**Ingredients:**\n\n- 1 packet Maggi noodles\n- 1 cup water\n- 1 tablespoon oil\n- 1/2 teaspoon salt\n- 1/4 teaspoon turmeric powder\n- 1/4 teaspoon red chili powder\n- 1/4 teaspoon garam masala\n- 1/4 teaspoon coriander powder\n- 1/2 teaspoon lemon juice\n- Chopped coriander leaves for garnish\n\n**Instructions:**\n\n1. Bring 1 cup of water to a boil in a saucepan or pot.\n2. Add the Maggi noodles, salt, turmeric powder, red chili powder, garam masala, and coriander powder.\n3. Stir well and let it cook for 2-3 minutes, or until the noodles are soft.\n4. Add 1 tablespoon of oil and stir fry for another minute.\n5. Remove from heat and add lemon juice.\n6. Garnish with chopped coriander leaves.\n\n**Tips:**\n\n- You can add chopped vegetables like carrots, peas, and onions to make the Maggi more nutritious and flavorful.\n- If you like a spicy Maggi, you can add more red chili powder or green chilies.\n- You can also add a beaten egg to the Maggi while it is cooking to make it more protein-rich.\n- Serve the Maggi hot with a dollop of tomato ketchup or green chutney.\n\nEnjoy your delicious and easy-to-make Maggi!"
            }
          ]
        },
        {
          "role": "user",
          "parts": [
            {
              "text": m.text,
            }
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.9,
        "topK": 1,
        "topP": 1,
        "maxOutputTokens": 1000,
        "stopSequences": []
      },
      "safetySettings": [
        {
          "category": "HARM_CATEGORY_HARASSMENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_HATE_SPEECH",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        },
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "threshold": "BLOCK_MEDIUM_AND_ABOVE"
        }
      ]
    };

    await http
        .post(Uri.parse(base_url), headers: header, body: jsonEncode(data))
        .then((value) {
      if (value.statusCode == 200) {
        var result = jsonDecode(value.body);
        print(result);
        print(result['candidates'][0]['content']['parts'][0]['text']);

        ChatMessage m1 = ChatMessage(
            user: bot,
            createdAt: DateTime.now(),
            text: result['candidates'][0]['content']['parts'][0]['text']);

        allmsg.insert(0, m1);
        setState(() {});
      }
    }).catchError((onError) {});
    typing.remove(bot);
    setState(() {});
  }
}
