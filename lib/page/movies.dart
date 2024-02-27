import 'package:flutter/material.dart';
import 'package:movies_watcher_fschmatz/page/store_movie.dart';
import '../entity/no_yes.dart';

class Movies extends StatefulWidget {
  NoYes watched;

  Movies({Key? key, required this.watched}) : super(key: key);

  @override
  _MoviesState createState() => _MoviesState();
}

class _MoviesState extends State<Movies> {
  List<Map<String, dynamic>> moviesList = [];

  //final dbLivro = LivroDao.instance;
  bool loading = true;

  @override
  void initState() {
    getLivrosState();
    super.initState();
  }

  void getLivrosState() async {
    /*  var resp = await dbLivro.queryAllLivrosByEstado(widget.bookState);
    listaLivros = resp;


   */
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: (loading)
            ? const Center(child: SizedBox.shrink())
            : (moviesList.isEmpty)
                ? const Center(
                    child: Text(
                    '??',
                    style: TextStyle(fontSize: 16),
                  ))
                : ListView(
                    children: [




                      ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(
                          height: 4,
                        ),
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: moviesList.length,
                        itemBuilder: (context, int index) {
                          return const SizedBox(
                            height: 50,
                          );
                          /* CardLivro(
                          key: UniqueKey(),
                          livro: Livro(
                            id: listaLivros[index]['idLivro'],
                            nome: listaLivros[index]['nome'],
                            numPaginas: listaLivros[index]['numPaginas'],
                            autor: listaLivros[index]['autor'],
                            lido: listaLivros[index]['lido'],
                            capa: listaLivros[index]['capa'],
                          ),
                          getLivrosState: getLivrosState,
                          paginaAtual: widget.bookState,
                        );*/
                        },
                      ),
                      const SizedBox(
                        height: 50,
                      )
                    ],
                  ),
       /* floatingActionButton: FloatingActionButton(
          heroTag: null,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => StoreMovie(
                    key: UniqueKey(),
                  ),
                ));
            //reload
                //.then((value) => getAllChannels());
          },
          child: const Icon(
            Icons.add_outlined,
          ),
        )*/
    );
  }
}
