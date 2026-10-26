%{
    #include <frontend/parser/yacc.h>
    #include <frontend/parser/scanner.h>
    #include <frontend/parser/location.hh>
    #include <frontend/parser/parser.h>
    #include <cerrno>
    #include <cstdlib>
    #include <cmath>
    #include <stdexcept>
    #include <string>
    #include <limits>

    using namespace FE;

    static location loc;

    #define YY_USER_ACTION      \
        loc.step();             \
        loc.columns(yyleng);

    #define yywrap() 1
    #define RETT(x, y) \
        return YaccParser::make_##x(y);

    #define TAB_WIDTH 4

    int handleTab();
    long long convertToInt(const char* str, const char end, bool& isLongLong);
    float convertToFloatDec(const char* str);
    float convertToFloatHex(const char* str);
    YaccParser::symbol_type makeIntConst(const char* text, const location& loc, Parser& parser);
    YaccParser::symbol_type makeFloatDec(const char* text, const location& loc, Parser& parser);
    YaccParser::symbol_type makeFloatHex(const char* text, const location& loc, Parser& parser);
%}

%option c++
%option noyywrap debug
%option yyclass="Scanner"
%option prefix="Yacc_"

%x COMMENT

digit       [0-9]
nonzero     [1-9]
octdigit    [0-7]
hexdigit    [0-9a-fA-F]
ident       [A-Za-z_][A-Za-z0-9_]*
hex_prefix  0[xX]
dec_exp     [eE][+-]?{digit}+
hex_exp     [pP][+-]?{digit}+
dec_float   ({digit}*\.{digit}+|{digit}+\.){dec_exp}?|{digit}+{dec_exp}
hex_float   {hex_prefix}({hexdigit}+(\.{hexdigit}*)?|\.{hexdigit}+){hex_exp}
hex_int     {hex_prefix}{hexdigit}+
oct_int     0{octdigit}*
dec_int     {nonzero}{digit}*

%%

\n              {
                    loc.lines(yyleng);
                    loc.step();
                }

[ \f\r\v]+      { }
[\t]            { loc.columns(handleTab()); }

"//".*          { }

"/*"            { BEGIN(COMMENT); }
<COMMENT>"*/"   { BEGIN(INITIAL); }
<COMMENT>\n     {
                    loc.lines(yyleng);
                    loc.step();
                }
<COMMENT>[\t]   { loc.columns(handleTab()); }
<COMMENT>.      { }
<COMMENT><<EOF>> {
                    _parser.reportError(loc, "unterminated block comment");
                    BEGIN(INITIAL);
                    return YaccParser::make_ERR_TOKEN(std::string("/*"), loc);
                }

"if"            { RETT(IF, loc) }
"else"          { RETT(ELSE, loc) }
"for"           { RETT(FOR, loc) }
"while"         { RETT(WHILE, loc) }
"continue"      { RETT(CONTINUE, loc) }
"break"         { RETT(BREAK, loc) }
"switch"        { RETT(SWITCH, loc) }
"case"          { RETT(CASE, loc) }
"goto"          { RETT(GOTO, loc) }
"do"            { RETT(DO, loc) }
"return"        { RETT(RETURN, loc) }
"const"         { RETT(CONST, loc) }
"int"           { RETT(INT, loc) }
"float"         { RETT(FLOAT, loc) }
"void"          { RETT(VOID, loc) }

"=="            { RETT(EQ, loc) }
"!="            { RETT(NE, loc) }
"<="            { RETT(LE, loc) }
">="            { RETT(GE, loc) }
"&&"            { RETT(AND, loc) }
"||"            { RETT(OR, loc) }
"="             { RETT(ASSIGN, loc) }
"!"             { RETT(NOT, loc) }
"<"             { RETT(LT, loc) }
">"             { RETT(GT, loc) }
"+"             { RETT(PLUS, loc) }
"-"             { RETT(MINUS, loc) }
"*"             { RETT(STAR, loc) }
"/"             { RETT(SLASH, loc) }
"%"             { RETT(MOD, loc) }

";"             { RETT(SEMICOLON, loc) }
","             { RETT(COMMA, loc) }
"("             { RETT(LPAREN, loc) }
")"             { RETT(RPAREN, loc) }
"["             { RETT(LBRACKET, loc) }
"]"             { RETT(RBRACKET, loc) }
"{"             { RETT(LBRACE, loc) }
"}"             { RETT(RBRACE, loc) }

{hex_float}     { return makeFloatHex(yytext, loc, _parser); }
{dec_float}     { return makeFloatDec(yytext, loc, _parser); }
{hex_int}       { return makeIntConst(yytext, loc, _parser); }
{oct_int}       { return makeIntConst(yytext, loc, _parser); }
{dec_int}       { return makeIntConst(yytext, loc, _parser); }

{ident} {
    auto str = std::string(yytext);
    return YaccParser::make_IDENT(str, loc);
}

\"[^\"]*\" {
    std::string str(yytext);
    if (!str.empty()) str = str.substr(1, str.size() - 2);
    return YaccParser::make_STR_CONST(str, loc);
}

<<EOF>>         { RETT(END, loc); }

. {
    auto str = std::string(yytext);
    _parser.reportError(loc, std::string("unexpected character: ") + str);
    return YaccParser::make_ERR_TOKEN(str, loc);
}

%%

int handleTab()
{
    int& c = loc.begin.column;
    return TAB_WIDTH - ((c - 1) % TAB_WIDTH) - 1;
}

long long convertToInt(const char* str, const char end, bool& isLongLong)
{
    if (str == nullptr) throw std::invalid_argument("null integer literal");

    errno           = 0;
    char*     tail  = nullptr;
    long long value = std::strtoll(str, &tail, 0);

    if (tail == str || tail == nullptr || *tail != end)
        throw std::invalid_argument(std::string(str) + " is not a complete integer literal");
    if (errno == ERANGE) throw std::out_of_range(std::string(str) + " is outside the long long range");

    isLongLong = value > std::numeric_limits<int>::max() || value < std::numeric_limits<int>::min();
    return value;
}

float convertToFloatDec(const char* str)
{
    if (str == nullptr) throw std::invalid_argument("null floating literal");

    errno       = 0;
    char* tail  = nullptr;
    float value = std::strtof(str, &tail);

    if (tail == str || tail == nullptr || *tail != '\0')
        throw std::invalid_argument(std::string(str) + " is not a complete floating literal");
    if (!std::isfinite(value)) throw std::out_of_range(std::string(str) + " overflows float");
    if (errno == ERANGE && value == 0.0f) throw std::out_of_range(std::string(str) + " underflows float");

    return value;
}

float convertToFloatHex(const char* str)
{
    return convertToFloatDec(str);
}

YaccParser::symbol_type makeIntConst(const char* text, const location& loc, Parser& parser)
{
    try
    {
        bool      isLL   = false;
        long long result = convertToInt(text, '\0', isLL);
        if (isLL) return YaccParser::make_LL_CONST(result, loc);
        return YaccParser::make_INT_CONST(static_cast<int>(result), loc);
    }
    catch (const std::exception& e)
    {
        parser.reportError(loc, std::string("Error parsing integer: ") + e.what());
        return YaccParser::make_ERR_TOKEN(std::string(text), loc);
    }
}

YaccParser::symbol_type makeFloatDec(const char* text, const location& loc, Parser& parser)
{
    try
    {
        return YaccParser::make_FLOAT_CONST(convertToFloatDec(text), loc);
    }
    catch (const std::exception& e)
    {
        parser.reportError(loc, std::string("Error parsing decimal float: ") + e.what());
        return YaccParser::make_ERR_TOKEN(std::string(text), loc);
    }
}

YaccParser::symbol_type makeFloatHex(const char* text, const location& loc, Parser& parser)
{
    try
    {
        return YaccParser::make_FLOAT_CONST(convertToFloatHex(text), loc);
    }
    catch (const std::exception& e)
    {
        parser.reportError(loc, std::string("Error parsing hexadecimal float: ") + e.what());
        return YaccParser::make_ERR_TOKEN(std::string(text), loc);
    }
}
