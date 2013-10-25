library mini_ast;

import 'package:parsers/parsers.dart';

final reservedNames = ["namespace",
                       "interface",
                       "dictionary",
                       "void"];

class AttributeDeclaration {
  final attribute;

  AttributeDeclaration(this.attribute);

  String toString() => "Attribute($attribute)";
}

class NamespaceDeclaration {
  final String name;
  final List body;
  final List<String> doc;
  final AttributeDeclaration attribute;

  NamespaceDeclaration(this.name, this.body, [this.doc, this.attribute]);

  String toString() => "$attribute NamespaceDeclaration($name, $body, $doc)";
}

class InterfaceDeclaration {
  final String name;
  final List body;
  final List<String> doc;

  InterfaceDeclaration(this.name, this.body, [this.doc]);

  String toString() => "InterfaceDeclaration($name, $body, $doc)";
}

class DictionaryDeclaration {
  final String name;
  final List body;
  final List<String> doc;

  DictionaryDeclaration(this.name, this.body, [this.doc]);

  String toString() => "DictionaryDeclaration($name, $body, $doc)";
}

class TypeAppl {
  final String name;
  final List<TypeAppl> arguments;

  TypeAppl(this.name, this.arguments);

  String toString() => "TypeAppl($name, $arguments)";
}

class Parameter {
  final String name;
  final TypeAppl type;
  final bool isArray;

  Parameter(this.type, this.name, [this.isArray = false]);

  String toString() => "Parameter($type, $name, isArray: $isArray)";
}

class MethodDeclaration {
  TypeAppl returnType;
  String name;
  List parameters;
  List<String> doc;

  MethodDeclaration(this.returnType, this.name, this.parameters, [this.doc]);

  String toString() =>
      "MethodDeclaration($returnType, $name, $parameters, $doc)";
}

class FieldDeclaration {
  TypeAppl type;
  String name;
  List<String> doc;

  FieldDeclaration(this.type, this.name, [this.doc]);

  String toString() => "FieldDeclaration($type, $name, $doc)";
}

AttributeDeclaration attributeMapping(attribute) =>
    new AttributeDeclaration(attribute);

NamespaceDeclaration namespaceDeclarationMapping(List<String> doc,
                                                 AttributeDeclaration attribute,
                                                 _, String name, List body,
                                                 __) =>
    new NamespaceDeclaration(name, body, doc, attribute);

InterfaceDeclaration interfaceDeclarationMapping(List<String> doc, _,
                                                 String name, List body, __) =>
    new InterfaceDeclaration(name, body, doc);

MethodDeclaration methodDeclarationRegularMapping(List<String> doc,
                                                  TypeAppl returnType,
                                                  String name,
                                                  List parameters, _) =>
  new MethodDeclaration(returnType, name, parameters, doc);

MethodDeclaration methodDeclarationReservedMapping(List<String> doc,
                                                   String returnType,
                                                   String name,
                                                   List parameters, _) =>
  new MethodDeclaration(new TypeAppl(returnType, null), name,
      parameters, doc);

DictionaryDeclaration dictionaryDeclarationMapping(List<String> doc, _,
                                                   String name,
                                                   List body, __) =>
    new DictionaryDeclaration(name, body, doc);

FieldDeclaration fieldDeclarationMapping(List<String> doc, TypeAppl type,
                                         String name, _) =>
  new FieldDeclaration(type, name, doc);

class DataCoreParser extends LanguageParsers {

  DataCoreParser() : super(reservedNames: reservedNames,
                           // Dont handle comments
                           commentStart: "",
                           commentEnd: "",
                           commentLine: "");

  Parser get docString => lexeme(_docStringOrSpaces.many);

  Parser get _docStringOrSpaces =>
        everythingBetween(string('//'), string('\n'))
      | everythingBetween(string('/*'), string('*/'), nested: true)
      | everythingBetween(string('/**'), string('*/'), nested: true);

  Parser get attribute =>
      brackets(identifier)
      ^ attributeMapping;

  Parser get namespaceDeclaration =>
      docString
      + attribute
      + reserved["namespace"]
      + identifier
      + braces(namespaceBody)
      + semi
      ^ namespaceDeclarationMapping;

  Parser get namespaceBody => body.many;

  Parser get body => interfaceDeclaration | dictionaryDeclaration;

  Parser get interfaceDeclaration =>
      docString
      + reserved["interface"]
      + identifier
      + braces(interfaceBody)
      + semi
      ^ interfaceDeclarationMapping;

  Parser get interfaceBody => method.many;

  Parser get method => regularMethod | voidMethod;

  Parser typeAppl() =>
      identifier
      + angles(rec(typeAppl).sepBy(comma)).orElse([])
      ^ (c, args) => new TypeAppl(c, args);

  Parser get parameterArray =>
      identifier  + symbol('[') + symbol(']')
      ^ (i, _, __) => i;

  Parser get parameter =>
      ((typeAppl() % 'type')
      + (parameterArray % 'parameter')
      ^ (t, p) => new Parameter(t, p, true))
      |
      ((typeAppl() % 'type')
      + (identifier % 'parameter')
      ^ (t, p) => new Parameter(t, p));


  Parser get regularMethod =>
      docString
      + typeAppl()
      + identifier
      + parens(parameter.sepBy(comma))
      + semi
      ^ methodDeclarationRegularMapping;

  Parser get voidMethod =>
      docString
      + reserved['void']
      + identifier
      + parens(parameter.sepBy(comma))
      + semi
      ^ methodDeclarationReservedMapping;

  Parser get dictionaryDeclaration =>
      docString
      + reserved["dictionary"]
      + identifier
      + braces(dictionaryBody)
      + semi
      ^ dictionaryDeclarationMapping;

  Parser get dictionaryBody => field.many;

  Parser get field => regularField;

  Parser get regularField =>
      docString
      + typeAppl()
      + identifier
      + semi
      ^ fieldDeclarationMapping;
}

final test = """

// Data core processor package
// Second comment line
[someattribute]
namespace datacore {
  // Defined interface of the processor
  interface DataProc {
    // Loads data for the processor as object array
    bool loadData(array data, int size);

    // Loads data for the processor as int array
    void load(int data[]);

    // Executes the processor
    void run();

    /* Returns the result of the processor */
    DataProcResult result();
  };

  /**
   * A data type for the processor result
   * Multi line comment
   * With information. 
   */
  dictionary DataProcResult {
    // Time spent processing
    double timeSpent;

    // Value calculated from processing
    int value;
  };
};
""";

void main() {
  DataCoreParser dataCoreParser = new DataCoreParser();
  NamespaceDeclaration namespaceDeclaration =
      dataCoreParser.namespaceDeclaration.between(spaces, eof).parse(test);
  print(namespaceDeclaration);
}
