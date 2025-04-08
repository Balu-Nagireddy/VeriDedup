<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VeriDedup</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <header>
        <h1>Welcome to VeriDedup</h1>
        <nav>
            <ul>
                <li><a href="welcome.jsp" class="active">Home</a></li>
                <li>
                    <a href="#">Login</a>
                    <ul>
                        <li><a href="admin.jsp">Admin</a></li>
                        <li><a href="client.jsp">Client</a></li>
                        <li><a href="host.jsp">CSP</a></li>
                    </ul>
                </li>
                <li><a href="register.jsp">Register</a></li>
                <li><a href="contact.jsp">Contact Us</a></li>
                <li><a href="about.jsp">About Us</a></li>
            </ul>
        </nav>
    </header>

    <section>
        <h2>Project Abstract: VeriDedup</h2>
        <h3>A Verifiable Cloud Data Deduplication Scheme with Integrity and Duplication Proof</h3>

        <h4>Problem Statement</h4>
        <p>Cloud storage providers (CSPs) often use deduplication to eliminate redundant data and optimize storage. However, two critical challenges arise:</p>
        <ul>
            <li><strong>Integrity Risks:</strong> The CSP might tamper with or delete deduplicated data, compromising its authenticity.</li>
            <li><strong>Duplication Fraud:</strong> A dishonest CSP could falsely claim non-duplicate data to charge users extra for storage they don’t use.</li>
        </ul>

        <h4>Innovative Solution</h4>
        <p><strong>VeriDedup</strong> introduces a groundbreaking framework to ensure both <strong>data integrity</strong> and <strong>duplication-proof accountability</strong> in cloud storage. By combining cryptographic protocols and novel verification mechanisms, it addresses the limitations of existing systems, such as brute-force attack vulnerabilities and inflexible tag generation.</p>

        <h4>Key Features</h4>
        <ul>
            <li><strong>Tag-Flexible Integrity Check Protocol (TDICP):</strong>
                <ul>
                    <li>Enables users to generate <strong>unique verification tags</strong> while supporting deduplication.</li>
                    <li>Uses <em>Private Information Retrieval (PIR)</em> to embed "note sets" (randomized sequences) into encrypted data for tamper-proof integrity checks.</li>
                </ul>
            </li>
            <li><strong>User-Determined Duplication Check Protocol (UDDCP):</strong>
                <ul>
                    <li>Leverages <em>Private Set Intersection (PSI)</em> to let users independently verify duplication claims, preventing CSP fraud.</li>
                    <li>Ensures the CSP cannot falsify duplication results to overcharge users.</li>
                </ul>
            </li>
        </ul>

        <h4>Security & Efficiency</h4>
        <ul>
            <li><strong>Formal Proofs:</strong> Rigorous analysis confirms resistance to brute-force attacks and CSP cheating.</li>
            <li><strong>Real-World Validation:</strong> Simulations based on actual datasets show <strong>20% faster integrity checks</strong> and <strong>30% lower communication costs</strong> compared to prior solutions like StealthGuard.</li>
        </ul>

        <h4>Impact</h4>
        <p>VeriDedup empowers users with <strong>transparent, secure deduplication</strong> while enabling CSPs to maintain storage efficiency. Its dual-protocol design sets a new standard for verifiable cloud storage, balancing security, flexibility, and performance.</p>

        <h4>Ideal For</h4>
        <p>Cloud service providers, enterprises managing large-scale data, and researchers in secure distributed systems.</p>

        <h3>Explore VeriDedup — where integrity meets accountability in the cloud. 🌩️🔒</h3>
    </section>

    <script src="script.js" defer></script>
    <footer>
	    <p>© 2025 VeriDedup | Secure Data Deduplication</p>
	</footer>
</body>
</html>
