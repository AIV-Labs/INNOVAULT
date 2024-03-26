import 'package:flutter/material.dart';

import '../Components/AppStructure/UnderContruction.dart';


const TextStyle optionTitleStyle = TextStyle(fontSize: 13, fontWeight: FontWeight.bold);
const TextStyle optionSubtitleStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.normal);
const TextStyle suboptionTitleStyle = TextStyle(fontSize: 10, fontWeight: FontWeight.bold);
const iconSize = 15.0;
class OptionsPage extends StatefulWidget {
  const OptionsPage({super.key});

  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {

  String? _selectedOption = 'Company Users';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Column(
        children: [
          Expanded(child: Row(
            children: [
              // listview of options

              Expanded(child: Container(
                // inner shadow

                child: ListView(
                  children:  [
                    ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      childrenPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      // dense: true,

                      title: const Text('Global Settings', style: optionTitleStyle,),
                      subtitle: const Text('Manage application settings', style: optionSubtitleStyle,),
                      // initiallyExpanded: true,
                      leading: const Icon(Icons.settings, size: iconSize,),
                      children: <Widget>[
                        ListTile(
                          title: const Text('Appearance', style: suboptionTitleStyle,),
                          onTap: (){
                            setState(() {
                              _selectedOption = 'GB-Appearance';
                            });
                          }
                          ,),

                        ListTile(
                          title: const Text('Language And Region', style: suboptionTitleStyle,),
                          onTap: (){
                            setState(() {
                              _selectedOption = 'GB-LanguageRegion';
                            });
                          }
                          ,),
                      ],
                    ),
                 ExpansionTile(

                title: const Text('Users Management', style: optionTitleStyle,),
                            subtitle: const Text('Manage company users', style: optionSubtitleStyle,),
                            // initiallyExpanded: true,
                            leading: const Icon(Icons.people, size: iconSize, ),
                            children: <Widget>[
                ListTile(title: const Text('Company users', style: suboptionTitleStyle,),
                  onTap: (){
                  setState(() {
                    _selectedOption = 'Company Users';
                  });
                }
                  ,),
                            ],
                          ),

                    ExpansionTile(

                      title: const Text('Contact Developers', style: optionTitleStyle,),
                      subtitle: const Text('Report bugs and request features', style: optionSubtitleStyle,),
                      // initiallyExpanded: true,
                      leading: const Icon(Icons.bug_report_rounded, size: iconSize,),
                      children: <Widget>[
                        ListTile(title: const Text('Report A bug', style: suboptionTitleStyle,),
                          onTap: (){
                            setState(() {
                              _selectedOption = 'RB-ReportBug';
                            });
                          }
                          ,),
                        ListTile(title: const Text('Request A Feature', style: suboptionTitleStyle,),
                          onTap: (){
                            setState(() {
                              _selectedOption = 'RB-RequestFeatures';
                            });
                          }
                          ,),
                      ],
                    ),

                // container  of the selected option


                ]),
              )),


              // Content
              Expanded(
                flex: 4,
                child:

                Padding(

                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: LayoutBuilder
                  (builder: (context, constraints) {
                  // return RegistrationForm();
                  switch (_selectedOption) {
                  case 'Company Users':
                  return const UnderConstruction();

                  default:
                  return const UnderConstruction();
                  }
              }
              ),
                ),

              ),
              const SizedBox(
                width: 50,
              )
            ],
          )),
        ],
      ),

    );
  }
}



