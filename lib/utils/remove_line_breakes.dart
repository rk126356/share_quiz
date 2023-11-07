String removeExtraLineBreaks(String text) {
  // Split the text into lines
  List<String> lines = text.split('\n');

  // Remove consecutive empty lines and join the remaining lines with '\n'
  List<String> resultLines = [];

  for (String line in lines) {
    if (line.trim().isNotEmpty) {
      resultLines.add(line);
    } else if (resultLines.isNotEmpty && resultLines.last.trim().isNotEmpty) {
      resultLines.add(''); // Add a single line break to maintain space
    }
  }

  return resultLines.join('\n');
}
