"""Verify repository content hashes after GPG signature verification."""
import hashlib
import pathlib
import sys

root = pathlib.Path(sys.argv[1]).resolve()
release_root = root / "dists/stable"
release = (release_root / "Release").read_text()
assert "Valid-Until:" in release, "Missing expiry"
sha_section = release.split("SHA256:\n", 1)[1].split("\nSHA512:", 1)[0]
for line in sha_section.strip().splitlines():
    digest, size, name = line.split()
    path = (release_root / name).resolve()
    assert path.is_relative_to(release_root), "Unsafe index path"
    data = path.read_bytes()
    assert len(data) == int(size) and hashlib.sha256(data).hexdigest() == digest, name
packages = (release_root / "main/binary-aarch64/Packages").read_text()
for paragraph in packages.strip().split("\n\n"):
    fields = dict(line.split(": ", 1) for line in paragraph.splitlines() if line and not line[0].isspace())
    path = (root / fields["Filename"]).resolve()
    assert path.is_relative_to(root), "Unsafe package path"
    data = path.read_bytes()
    assert len(data) == int(fields["Size"]), path
    assert hashlib.sha256(data).hexdigest() == fields["SHA256"], path
    print(f'Verified {fields["Package"]} {fields["Version"]} {fields["Architecture"]}')
