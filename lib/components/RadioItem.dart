import 'package:flutter/material.dart';
class RadioItem extends StatelessWidget {
  final RadioModel _item;
  RadioItem(this._item);
  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.all(15.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            flex:1,
            child: Container(
              height: 35.0,
              width: 35.0,
              child: Icon(
                _item.next,
                color:
                Theme.of(context)
                    .accentColor,
              ),
            ),
          ),
          Expanded(
            flex:5,
            child: new Container(
              margin: new EdgeInsets.only(left: 10.0),
              child: new Text(_item.text,  style: TextStyle(
                  fontSize: 16.0,
                  color:
                  Colors.black),),
            ),
          ),
          new Container(
            height: 20.0,
            width: 20.0,
            child: new Center(
              child: new Text("",
                  style: new TextStyle(
                      color:
                      _item.isSelected ? Colors.white : Colors.black,
                      //fontWeight: FontWeight.bold,
                      fontSize: 12.0)),
            ),
            decoration: new BoxDecoration(
              color: _item.isSelected
                  ? Colors.red
                  : Colors.transparent,
              border: new Border.all(
                  width: 2.0,
                  color: _item.isSelected
                      ? Colors.red
                      : Colors.black),
              borderRadius: const BorderRadius.all(const Radius.circular(20.0)),
            ),
          ),


        ],
      ),
    );
  }
}
class RadioModel {
  bool isSelected;
  final String buttonText;
  final String text;
  final IconData next;

  RadioModel(this.isSelected,this.text, this.buttonText, this.next);
}