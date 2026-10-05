import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

// ============================================================
// CORES DO APLICATIVO
// ============================================================

const Color primaryColor = Color(0xFF6C63FF);
const Color secondaryColor = Color(0xFF00C9A7);
const Color backgroundColor = Color(0xFFF7F7FC);
const Color darkText = Color(0xFF25243A);

// ============================================================
// MODELO - TAREFA
// ============================================================

enum Categoria {
  estudos,
  trabalho,
  pessoal,
}

enum Prioridade {
  baixa,
  media,
  alta,
}

class Tarefa {
  final String id;
  String titulo;
  String descricao;
  bool concluida;
  Categoria categoria;
  Prioridade prioridade;
  DateTime? data;

  Tarefa({
    required this.id,
    required this.titulo,
    this.descricao = '',
    this.concluida = false,
    this.categoria = Categoria.pessoal,
    this.prioridade = Prioridade.media,
    this.data,
  });
}

// ============================================================
// APLICATIVO
// ============================================================

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool modoEscuro = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '2Do Pro',

      themeMode: modoEscuro ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,

        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),

        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: darkText,
        ),

        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
      ),

      home: TarefaScreen(
        modoEscuro: modoEscuro,
        onTemaAlterado: () {
          setState(() {
            modoEscuro = !modoEscuro;
          });
        },
      ),
    );
  }
}

// ============================================================
// TELA PRINCIPAL
// ============================================================

class TarefaScreen extends StatefulWidget {
  final bool modoEscuro;
  final VoidCallback onTemaAlterado;

  const TarefaScreen({
    super.key,
    required this.modoEscuro,
    required this.onTemaAlterado,
  });

  @override
  State<TarefaScreen> createState() => _TarefaScreenState();
}

class _TarefaScreenState extends State<TarefaScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _pesquisaController =
      TextEditingController();

  final List<Tarefa> _tarefas = [
    Tarefa(
      id: '1',
      titulo: 'Estudar para o ENEM',
      descricao: 'Revisar matemática e química',
      categoria: Categoria.estudos,
      prioridade: Prioridade.alta,
      data: DateTime.now(),
    ),
    Tarefa(
      id: '2',
      titulo: 'Finalizar projeto Flutter',
      descricao: 'Melhorar interface do aplicativo',
      categoria: Categoria.trabalho,
      prioridade: Prioridade.media,
      data: DateTime.now(),
    ),
    Tarefa(
      id: '3',
      titulo: 'Ir à academia',
      categoria: Categoria.pessoal,
      prioridade: Prioridade.baixa,
      concluida: true,
    ),
  ];

  String _pesquisa = '';
  String _filtro = 'Todas';

  // ==========================================================
  // FILTRAR TAREFAS
  // ==========================================================

  List<Tarefa> get _tarefasFiltradas {
    List<Tarefa> resultado = List.from(_tarefas);

    // Pesquisa
    if (_pesquisa.isNotEmpty) {
      resultado = resultado.where((tarefa) {
        return tarefa.titulo
                .toLowerCase()
                .contains(_pesquisa.toLowerCase()) ||
            tarefa.descricao
                .toLowerCase()
                .contains(_pesquisa.toLowerCase());
      }).toList();
    }

    // Filtro
    if (_filtro == 'Pendentes') {
      resultado =
          resultado.where((tarefa) => !tarefa.concluida).toList();
    }

    if (_filtro == 'Concluídas') {
      resultado =
          resultado.where((tarefa) => tarefa.concluida).toList();
    }

    return resultado;
  }

  // ==========================================================
  // ADICIONAR / EDITAR TAREFA
  // ==========================================================

  void _abrirFormulario({Tarefa? tarefa}) {
    _controller.text = tarefa?.titulo ?? '';

    Categoria categoriaSelecionada =
        tarefa?.categoria ?? Categoria.pessoal;

    Prioridade prioridadeSelecionada =
        tarefa?.prioridade ?? Prioridade.media;

    DateTime? dataSelecionada = tarefa?.data;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Barrinha
                    Center(
                      child: Container(
                        width: 45,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      tarefa == null
                          ? 'Criar nova tarefa'
                          : 'Editar tarefa',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Título
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      textCapitalization:
                          TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Nome da tarefa',
                        hintText: 'Ex: Estudar matemática',
                        prefixIcon:
                            const Icon(Icons.edit_outlined),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Categoria
                    const Text(
                      'Categoria',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      children: Categoria.values.map((categoria) {
                        return ChoiceChip(
                          label: Text(
                            _nomeCategoria(categoria),
                          ),
                          selected:
                              categoria == categoriaSelecionada,
                          onSelected: (_) {
                            setModalState(() {
                              categoriaSelecionada = categoria;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Prioridade
                    const Text(
                      'Prioridade',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      children: Prioridade.values.map((prioridade) {
                        return ChoiceChip(
                          label: Text(
                            _nomePrioridade(prioridade),
                          ),
                          selected:
                              prioridade == prioridadeSelecionada,
                          onSelected: (_) {
                            setModalState(() {
                              prioridadeSelecionada =
                                  prioridade;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Data
                    OutlinedButton.icon(
                      onPressed: () async {
                        final data = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                          initialDate:
                              dataSelecionada ?? DateTime.now(),
                        );

                        if (data != null) {
                          setModalState(() {
                            dataSelecionada = data;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        dataSelecionada == null
                            ? 'Adicionar data'
                            : 'Data: ${_formatarData(dataSelecionada!)}',
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Salvar
                    FilledButton.icon(
                      onPressed: () {
                        final texto =
                            _controller.text.trim();

                        if (texto.isEmpty) {
                          return;
                        }

                        setState(() {
                          if (tarefa == null) {
                            _tarefas.add(
                              Tarefa(
                                id: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                                titulo: texto,
                                categoria:
                                    categoriaSelecionada,
                                prioridade:
                                    prioridadeSelecionada,
                                data: dataSelecionada,
                              ),
                            );
                          } else {
                            tarefa.titulo = texto;
                            tarefa.categoria =
                                categoriaSelecionada;
                            tarefa.prioridade =
                                prioridadeSelecionada;
                            tarefa.data = dataSelecionada;
                          }
                        });

                        Navigator.pop(context);
                        _controller.clear();
                      },
                      icon: Icon(
                        tarefa == null
                            ? Icons.add
                            : Icons.check,
                      ),
                      label: Text(
                        tarefa == null
                            ? 'Criar tarefa'
                            : 'Salvar alterações',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // ALTERAR STATUS
  // ==========================================================

  void _alternarStatus(Tarefa tarefa) {
    setState(() {
      tarefa.concluida = !tarefa.concluida;
    });
  }

  // ==========================================================
  // EXCLUIR TAREFA
  // ==========================================================

  void _deletarTarefa(Tarefa tarefa) {
    final index = _tarefas.indexOf(tarefa);

    setState(() {
      _tarefas.remove(tarefa);
    });

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tarefa excluída'),
        action: SnackBarAction(
          label: 'DESFAZER',
          onPressed: () {
            setState(() {
              _tarefas.insert(index, tarefa);
            });
          },
        ),
      ),
    );
  }

  // ==========================================================
  // INFORMAÇÕES
  // ==========================================================

  String _nomeCategoria(Categoria categoria) {
    switch (categoria) {
      case Categoria.estudos:
        return '📚 Estudos';
      case Categoria.trabalho:
        return '💼 Trabalho';
      case Categoria.pessoal:
        return '👤 Pessoal';
    }
  }

  String _nomePrioridade(Prioridade prioridade) {
    switch (prioridade) {
      case Prioridade.baixa:
        return 'Baixa';
      case Prioridade.media:
        return 'Média';
      case Prioridade.alta:
        return 'Alta';
    }
  }

  Color _corPrioridade(Prioridade prioridade) {
    switch (prioridade) {
      case Prioridade.baixa:
        return Colors.green;
      case Prioridade.media:
        return Colors.orange;
      case Prioridade.alta:
        return Colors.red;
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final total = _tarefas.length;

    final concluidas =
        _tarefas.where((tarefa) => tarefa.concluida).length;

    final pendentes = total - concluidas;

    final progresso =
        total == 0 ? 0.0 : concluidas / total;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Minhas Tarefas',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Simples e produtivo.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Tema',
            onPressed: widget.onTemaAlterado,
            icon: Icon(
              widget.modoEscuro
                  ? Icons.light_mode
                  : Icons.dark_mode_outlined,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
          // ====================================================
          // CARD DE PROGRESSO
          // ====================================================

          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6C63FF),
                  Color(0xFF8B7CFF),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Seu progresso',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${(progresso * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progresso,
                    minHeight: 9,
                    backgroundColor:
                        Colors.white.withOpacity(0.25),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  '$concluidas concluídas • $pendentes pendentes',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // ====================================================
          // PESQUISA
          // ====================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: TextField(
              controller: _pesquisaController,
              onChanged: (valor) {
                setState(() {
                  _pesquisa = valor;
                });
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar tarefas...',
                prefixIcon: const Icon(
                  Icons.search,
                ),
                suffixIcon:
                    _pesquisa.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _pesquisaController.clear();

                              setState(() {
                                _pesquisa = '';
                              });
                            },
                            icon:
                                const Icon(Icons.close),
                          )
                        : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ====================================================
          // FILTROS
          // ====================================================

          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              children: [
                _filtroBotao('Todas'),
                _filtroBotao('Pendentes'),
                _filtroBotao('Concluídas'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ====================================================
          // LISTA
          // ====================================================

          Expanded(
            child: _tarefasFiltradas.isEmpty
                ? _estadoVazio()
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: 100,
                      top: 4,
                    ),
                    itemCount:
                        _tarefasFiltradas.length,
                    itemBuilder:
                        (context, index) {
                      final tarefa =
                          _tarefasFiltradas[index];

                      return _cardTarefa(tarefa);
                    },
                  ),
          ),
        ],
      ),

      // ========================================================
      // BOTÃO ADICIONAR
      // ========================================================

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.add),
        label: const Text(
          'Nova tarefa',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // BOTÃO DE FILTRO
  // ==========================================================

  Widget _filtroBotao(String texto) {
    final selecionado = _filtro == texto;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(texto),
        selected: selecionado,
        onSelected: (_) {
          setState(() {
            _filtro = texto;
          });
        },
      ),
    );
  }

  // ==========================================================
  // CARD DA TAREFA
  // ==========================================================

  Widget _cardTarefa(Tarefa tarefa) {
    return Dismissible(
      key: ValueKey(tarefa.id),
      direction: DismissDirection.endToStart,

      background: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding:
            const EdgeInsets.only(right: 25),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),

      onDismissed: (_) {
        _deletarTarefa(tarefa);
      },

      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: tarefa.concluida,
                activeColor: secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(6),
                ),
                onChanged: (_) {
                  _alternarStatus(tarefa);
                },
              ),

              const SizedBox(width: 4),

              // Conteúdo
              Expanded(
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(12),
                  onTap: () {
                    _abrirFormulario(
                      tarefa: tarefa,
                    );
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          tarefa.titulo,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                            decoration:
                                tarefa.concluida
                                    ? TextDecoration
                                        .lineThrough
                                    : null,
                            color: tarefa.concluida
                                ? Colors.grey
                                : null,
                          ),
                        ),

                        if (tarefa.descricao
                            .isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.only(
                              top: 4,
                            ),
                            child: Text(
                              tarefa.descricao,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),

                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _tag(
                              _nomeCategoria(
                                tarefa.categoria,
                              ),
                            ),

                            _tag(
                              _nomePrioridade(
                                tarefa.prioridade,
                              ),
                              cor: _corPrioridade(
                                tarefa.prioridade,
                              ),
                            ),

                            if (tarefa.data != null)
                              _tag(
                                _formatarData(
                                  tarefa.data!,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Menu
              PopupMenuButton<String>(
                onSelected: (valor) {
                  if (valor == 'editar') {
                    _abrirFormulario(
                      tarefa: tarefa,
                    );
                  }

                  if (valor == 'excluir') {
                    _deletarTarefa(tarefa);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'editar',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 10),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'excluir',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text('Excluir'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // TAG
  // ==========================================================

  Widget _tag(
    String texto, {
    Color? cor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: (cor ?? primaryColor)
            .withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: cor ?? primaryColor,
        ),
      ),
    );
  }

  // ==========================================================
  // ESTADO VAZIO
  // ==========================================================

  Widget _estadoVazio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              _pesquisa.isNotEmpty
                  ? Icons.search_off
                  : Icons.task_alt,
              size: 70,
              color: primaryColor.withOpacity(0.4),
            ),

            const SizedBox(height: 18),

            Text(
              _pesquisa.isNotEmpty
                  ? 'Nenhuma tarefa encontrada'
                  : 'Tudo limpo por aqui!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _pesquisa.isNotEmpty
                  ? 'Tente pesquisar por outro termo.'
                  : 'Crie uma tarefa e comece a organizar seu dia.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _pesquisaController.dispose();
    super.dispose();
  }
}