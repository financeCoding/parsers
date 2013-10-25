library new_chrome_idl_parser_and_model.dart;

import 'package:parsers/parsers.dart';

// note: choose between using reserved names or keywords
final reservedNames = [];
final keywords = [];
final typeMapping = {};

// namespace
class IDLNamespaceDeclaration {
  final String name;
//  final IDLFunctionDeclaration functionDeclaration;
//  final List<IDLTypeDeclaration> typeDeclarations;
//  final IDLEventDeclaration eventDeclaration;
//  final List<IDLCallbackDeclaration> callbackDeclarations;
//  final List<IDLEnumDeclaration> enumDeclarations;

  // The body will contain one of the above list of types.
  final List body;
  final List<String> documentation;
  IDLNamespaceDeclaration(this.name, this.body, this.documentation);

  String toString() => "";
}

// interface Functions
class IDLFunctionDeclaration {
  final String name = "Functions";
  final List<IDLMethod> methods;
  final List<String> documentation;

  String toString() => "";
}

// dictionary definition
class IDLTypeDeclaration {
  final List<IDLMember> members;
  final List<String> documentation;
  String toString() => "";
}

// interface Events
class IDLEventDeclaration {
  final String name = "Events";
  final List<IDLMethod> methods;
  final List<String> documentation;
  String toString() => "";
}

// callback definition
class IDLCallbackDeclaration {
  final String name;
  // TODO: fill out the rest of the callback signature
  final List<String> documentation;
  String toString() => "";
}

// enum definition
class IDLEnumDeclaration {
  final String name;
  final List<IDLEnumValue> values;
  final List<String> documentation;
  String toString() => "";
}

class IDLMethod {
  final String name;
  final List<IDLParameter> parameters;
  final IDLType returnType;
  final List<String> documentation;
  String toString() => "";
}

class IDLMember {
  final String name;
  final IDLType type;
  final List<String> documentation;
  String toString() => "";
}

class IDLParameter {
  final String name;
  final IDLType type;
  String toString() => "";
}

class IDLAttribute {
  String toString() => "";
}

class IDLEnumValue {
  final String name;
  final String value;
  String toString() => "";
}

class IDLType {
  final String name;
  String toString() => "";
}


// tood: create methods that return each of the above
// type when a parser match is found. see mini_ast.dart mapping section
IDLNamespaceDeclaration idlNamespaceDeclarationMapping(List<String> doc, _,
                                                       String name, List body,
                                                       __) =>
new IDLNamespaceDeclaration(name, body, doc);

class ChromeIDLParser extends LanguageParsers {
  ChromeIDLParser() : super(reservedNames: reservedNames,
                      // Dont handle comments
                      commentStart: "",
                      commentEnd: "",
                      commentLine: "");

  // Parse the namespace
  Parser get namespaceDeclaration =>
      // todo: does namespace come with annotation?
      docString
      + reserved["namespace"]
      + identifier
      + braces(namespaceBody)
      + semi
      ^ idlNamespaceDeclarationMapping;


  Parser get namespaceBody => _namespaceBody.many;

  Parser get _namespaceBody => functionDeclaration
                             | typeDeclaration
                             | eventDeclaration
                             | callbackDeclaration
                             | enumDeclaration;

  // Parse the interface Functions
  Parser get functionDeclaration => methods.many;
  Parser get methods => _methods;
  Parser get _methods => null;

  // Parse the dictionary definitions
  Parser get typeDeclaration => null;
  Parser get typeBody => fieldDeclared.many;
  Parser get fieldDeclared => null;

  // Parse the interface Events
  Parser get eventDeclaration => methods.many;

  // Parse the callback definitions
  Parser get callbackDeclaration => null;

  // Parse the enum declarations
  Parser get enumDeclaration => null;
  Parser get enumBody => enumValue;
  Parser get enumValue => null;

  /**
   * Parser all documentation strings and spaces between.
   */
  Parser get docString => lexeme(_docString.many);
  Parser get _docString =>
        everythingBetween(string('//'), string('\n'))
      | everythingBetween(string('/*'), string('*/'), nested: true)
      | everythingBetween(string('/**'), string('*/'), nested: true);

  Parser get parameter => null;
  Parser type() => null;
}


void main() {
  print("yay dart!");
}