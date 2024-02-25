import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StoreMovie extends StatefulWidget {
  const StoreMovie({super.key});

  @override
  State<StoreMovie> createState() => _StoreMovieState();
}

class _StoreMovieState extends State<StoreMovie> {

  TextEditingController controllerName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Opa!'),
        ),
        body: ListView(children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
             // autofocus: true,
              minLines: 1,
              maxLines: 3,
              maxLength: 200,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.name,
              controller: controllerName,

            /*  decoration: InputDecoration(
                  helperText: "* Obrigatório",
                  labelText: "Nome",
                  errorText: nomeValido ? null : "Nome vazio"),*/

            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: FilledButton.tonalIcon(
                onPressed: () {
                  /* if (validarTextFields()) {
                    _salvarLivro();
                    widget.refreshHome();
                    Navigator.of(context).pop();
                  } else {
                    setState(() {
                      nomeValido;
                    });
                  }*/
                },
                icon: const Icon(
                  Icons.save_outlined,
                ),
                label: const Text(
                  'Save',
                )),
          ),
        ]));
  }
}
