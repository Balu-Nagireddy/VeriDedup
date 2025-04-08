package com.veridedup;

import java.util.BitSet;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class CuckooFilter {
    private static final int FILTER_SIZE = 10000; // Define appropriate size
    private static final BitSet cuckooFilter = new BitSet(FILTER_SIZE);

    public static void insertTag(String tag) {
        int index = getIndex(tag);
        cuckooFilter.set(index);
    }

    public static boolean containsTag(String tag) {
        int index = getIndex(tag);
        return cuckooFilter.get(index);
    }

    private static int getIndex(String tag) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(tag.getBytes());
            return Math.abs(hash[0] % FILTER_SIZE); // Get a valid index
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 Algorithm not found", e);
        }
    }
}
