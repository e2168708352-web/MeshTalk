package com.bitchat.android.model

/**
 * Authorship checks that never trust the display name when a stable sender ID
 * is available.
 *
 * Names collide. A nearby peer, a group member, or a bridged sender can carry
 * exactly my nickname, so comparing [BitchatMessage.sender] against my nickname
 * treats their messages as mine: their rows stop counting as unread and a
 * namesake's conversation can be summarised as my own thread. [BitchatMessage.senderPeerID]
 * is the value the mesh actually keys on, so it decides whenever it is present;
 * the nickname is only a fallback for rows that carry no ID at all.
 */
object MessageAuthorship {

    /**
     * @param identifiers my own identities — nickname and peer IDs. Comparison
     *   is case-insensitive, so callers may pass either casing.
     */
    fun isOwn(message: BitchatMessage, identifiers: Set<String>): Boolean {
        val normalized = identifiers
            .filter { it.isNotBlank() }
            .mapTo(HashSet()) { it.lowercase() }
        if (normalized.isEmpty()) return false

        val senderId = message.senderPeerID?.takeIf { it.isNotBlank() }
        if (senderId != null) {
            return senderId.lowercase() in normalized
        }
        return message.sender.lowercase() in normalized
    }
}
