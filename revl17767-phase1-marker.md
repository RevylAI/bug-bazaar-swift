# REVL-17767 phase 1 marker

Push 1 (case a): build expected, no proof.
Push 2 (case d): labeled, build and proof expected.
Push 3 (case e): label removed, build expected, no proof.
Push 4 (case f): config without start, build and proof expected.
Push 5 (case g): start on_demand, no label, nothing expected.
Push 6 (case b): build expected, then Run proof from the signed-in browser.
