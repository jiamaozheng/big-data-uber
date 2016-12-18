package edu.uchicago.mpcs53013.uberDataIngest;

import java.io.File;
import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.io.BytesWritable;
import org.apache.thrift.TException;

public class UberData2015Processor extends UberDataProcessor {

    private Pattern pattern;
    private Matcher matcher;

    // Constructor
    UberData2015Processor(String inputDirectory, String outputDirectory, Configuration finalConf) throws IOException {
        super(inputDirectory, outputDirectory, finalConf, 2015);
        pattern = Pattern.compile("^(\\d+)-(\\d+)-(\\d+) (\\d+):(\\d+):(\\d+)$");
    }

    @Override
    void processLine(String line) throws IOException {
        appendInHDFS(line2record(line));
    }

    // Create a record object based on a raw data line, return null means discard the line
    private UberRecord2015 line2record(String line) {
        String[] strs = line.split(",");
        if (strs.length < 4 || strs[0].length() == 0 || strs[1].length() == 0 || strs[2].length() == 0 || strs[3].length() == 0) {
            return null;
        }

        // Column 1
        String dispatchBase = strs[0];

        // Column 2
        matcher = pattern.matcher(strs[1]);
        if (!matcher.find()) {
            return null;
        }
        short year = Short.parseShort(matcher.group(1));
        byte month = Byte.parseByte(matcher.group(2));
        byte day = Byte.parseByte(matcher.group(3));
        byte hour = Byte.parseByte(matcher.group(4));
        byte minute = Byte.parseByte(matcher.group(5));
        byte second = Byte.parseByte(matcher.group(6));

        // Column 3
        String base = strs[2];

        // Column 4
        short locationID = Short.parseShort(strs[3]);

        return new UberRecord2015(dispatchBase, year, month, day, hour, minute, second, base, locationID);
    }

    // Append the new record into HDFS
    private void appendInHDFS(UberRecord2015 record) throws IOException {
        if (record == null) {   // If a line has been discarded
            return;
        }
        try {
            writer.append(one, new BytesWritable(ser.serialize(record)));
        } catch (TException e) {
            throw new IOException(e);
        }
    }

    @Override
    boolean shouldProcess(File file) {
        return file.getName().equals("uber2015_01_to_06.csv");
    }

}



