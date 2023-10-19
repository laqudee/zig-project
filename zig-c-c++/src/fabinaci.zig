pub fn fabinaci(n: u128) u128 {
    if (n == 0) return 0;
    if (n == 1) return 1;
    return fabinaci(n - 1) + fabinaci(n - 2);
}
