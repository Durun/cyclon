package memoryLogAnalyzer

import java.io.BufferedReader
import java.lang.IllegalArgumentException
import java.nio.file.Paths
import java.time.Duration
import kotlin.math.max

fun main(args: Array<String>) {
    val fileName = runCatching { args[0] }
            .onFailure { println("args = ${args.joinToString()}") }
            .getOrThrow()

    val file = Paths.get(fileName).toFile()
    val message = analyzeMemoryLog(file.bufferedReader())
    println(message)
}


private fun analyzeMemoryLog(reader: BufferedReader): String {
    val date = reader.readLine()
    val entries = reader.lineSequence()
            .mapNotNull { line -> LogEntry.of(line) }
            .groupingBy { it.pid }
            .reduce { _, acc, elem -> LogEntry.maxEachOf(acc, elem) }
            .values

    return """
        $date
        pid${"\t\t"}cpu${"\t"}memory${"\t"}duration
        ${entries.joinToString("\n")}
        """.trimIndent()
}

private data class LogEntry(
        val pid: Int,
        val cpu: Int,
        val memory: Int,
        val duration: Duration?
) {
    companion object {
        fun of(line: String): LogEntry? {
            val columns = line.split(" ").filter { it.isNotBlank() }
            return runCatching {
                LogEntry(
                        pid = columns[0].toInt(),
                        cpu = columns[8].replace(".", "").toInt(),
                        memory = columns[9].replace(".", "").toInt(),
                        duration = columns[10].toDuration()
                )
            }.getOrNull()

        }

        fun maxEachOf(a: LogEntry, b:LogEntry): LogEntry {
            if (a.pid != b.pid) throw IllegalArgumentException()
            return LogEntry(
                    pid = a.pid,
                    cpu = maxOf(a.cpu, b.cpu),
                    memory = maxOf(a.memory, b.memory),
                    duration = maxOf(a.duration ?: Duration.ZERO, b.duration ?: Duration.ZERO)
            )
        }

        private fun String.toDuration(): Duration? {
            // mm:ss.SS
            val format = Regex("([0-9]+):([0-9]+)\\.([0-9]+)")
            val numbers = format.find(this)?.groupValues ?: return null
            return runCatching {
                val min = numbers[1]
                val sec = numbers[2]
                val csec = numbers[3]
                Duration.parse("PT${min}M${sec}.${csec}S")
            }.onFailure {
                println("failure to parse Duration $numbers")
            }.getOrNull()
        }
    }

    override fun toString(): String {
        return "$pid\t$cpu\t$memory\t$duration"
    }

}
