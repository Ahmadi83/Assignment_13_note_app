
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';



void main() async{
WidgetsFlutterBinding.ensureInitialized();

await Hive.initFlutter();
await Hive.openBox('NoteBox_app');

 runApp(MaterialApp(
   debugShowCheckedModeBanner: false,

   home: MyApp(),
 )) ;
}



class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

}


class _MyAppState extends State<MyApp> {


@override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshItem();
  }

  @override
  void  dispose(){
   tittle.dispose();
   description.dispose();
   super.dispose();
  }
  
  TextEditingController tittle = TextEditingController();
  TextEditingController description = TextEditingController();


  void refreshItem(){
    final data = _NoteBox_App.keys.map((Key){
      final item =_NoteBox_App.get(Key);
      return {"Key":Key,"name": item["name"],"description":item["description"]};
    }).toList();

    setState((){
      items = data.reversed.toList();
      print(items.length);
    });
  }



  List <Map<String,dynamic>> items=[];
  
  final _NoteBox_App = Hive.box('NoteBox_app');

  Future<void> createItem(Map<String,dynamic> newitem)async {
    await _NoteBox_App.add(newitem);
    refreshItem();
  }

  Future<void> UpdateItem(int itemkey, Map<String,dynamic> item)async {
   await _NoteBox_App.put(itemkey, item);
   refreshItem();
  }

  Future<void> DeleteItem(int itemkey)async {
    await _NoteBox_App.delete(itemkey);
    refreshItem();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('The Note  Has Deleted')
        ));
  }



  void  _showForm(BuildContext ctx,int? itemkey){

    if(itemkey !=null){
      final existingItem=
          items.firstWhere((element) => element['Key'] == itemkey);
      tittle.text =existingItem['name'];
      description.text =existingItem['description'];
    }

    showModalBottomSheet(
        context: ctx,
        elevation: 5,
        isScrollControlled: true,
        builder: (_)=> Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 15,
            left: 15,
            right: 15,),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:CrossAxisAlignment.end,
            children: [
              TextField(decoration: InputDecoration(hintText: 'Title'), controller: tittle,),
              SizedBox(height: 10,),
              TextField(decoration: InputDecoration(hintText: 'Description') ,controller: description,),
              SizedBox(height: 10,),

              MaterialButton(onPressed: () async{
                if(itemkey ==null){
                createItem({
                  'name': tittle.text,
                  'description':description.text
                });
                }
                else {
                  UpdateItem(itemkey, {
                    'name': tittle.text.trim(),
                    'description':description.text.trim(),
                  });
                }

                tittle.clear();
                description.clear();
                Navigator.of(ctx).pop();

              },
                child: Text(itemkey == null ? 'Save': 'Update'),
                color: Colors.blueAccent,
              ),
              SizedBox(height: 20,)
            ],
          ),

        )
    );
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context,null),
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),

      appBar: AppBar(
        title: const Text("Note App",style: TextStyle(fontWeight: FontWeight.w500,),),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
      ),


      body: ListView.builder(
        itemCount: items.length,
      itemBuilder:  (context, index) {
          final currentitem=items[index];

        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Card(
            color: Colors.orange.shade200,

            child: ListTile(
              title: Text(currentitem['name'],style: TextStyle(fontWeight: FontWeight.bold),),
              subtitle: Text(currentitem['description']),
              trailing: Row(mainAxisSize: MainAxisSize.min,
                children: [
                IconButton(onPressed: (){
                  _showForm(context, currentitem['Key']);}, icon:Icon(Icons.edit)),

                IconButton(onPressed: (){
                  DeleteItem( currentitem['Key']);}, icon: Icon(Icons.delete))
                ],)
            ),
          ),
        );
      },)

    );
  }
}
