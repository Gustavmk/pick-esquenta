docker login

# verfiy
cat ~/.docker/config.json

# Primeiro passo é pegar o conteúdo do seu arquivo config.json e codificar em base64, e para isso você pode usar o comando base64:
# decode to base64
base64 ~/.docker/config.json

# Então vamos lá! Crie um arquivo chamado dockerhub-secret.yaml com o seguinte conteúdo:

apiVersion: v1
kind: Secret
metadata:
  name: docker-hub-secret # nome do Secret
type: kubernetes.io/dockerconfigjson # tipo do Secret, neste caso é um Secret que armazena credenciais Docker
data:
  .dockerconfigjson: |  # substitua este valor pelo conteúdo do seu arquivo config.json codificado em base64
    QXF1aSB0ZW0gcXVlIGVzdGFyIG8gY29udGXDumRvIGRvIHNldSBjb25maWcuanNvbiwgY29pc2EgbGluZGEgZG8gSmVmaW0=
    ewoJImF1dGhzIjogewoJCSJodHRwczovL2luZGV4LmRvY2tlci5pby92MS8iOiB7CgkJCSJhdXRo
    IjogIlozVnpkR0YyYldzNk4yVk9PVWhaVkRJcWFBPT0iCgkJfSwKCQkibWVlcGFwcC5henVyZWNy
    LmlvIjogewoJCQkiYXV0aCI6ICJNREF3TURBd01EQXRNREF3TUMwd01EQXdMVEF3TURBdE1EQXdN
    REF3TURBd01EQXdPZz09IiwKCQkJImlkZW50aXR5dG9rZW4iOiAiZXlKaGJHY2lPaUpTVXpJMU5p
    SXNJblI1Y0NJNklrcFhWQ0lzSW10cFpDSTZJbHBDVmxrNlFsaEJUanBVUmtaVk9qTklXa3c2VGpR
    Mk5UcEtSbGN6T2twWE4wdzZURmxCVnpwUU5WTk5PbEpDVVVjNlMwc3pTRHBaUjFWRUluMC5leUpx
    ZEdraU9pSTVZVFkwWlRNeU1pMHpPR05oTFRRMU16SXRPVE5pWkMxbE5qSTBObU01TldaaVpUQWlM
    Q0p6ZFdJaU9pSm5kWE4wWVhadkxtdDFibTlBYldWbGNDNWpiMjB1WW5JaUxDSnVZbVlpT2pFM01E
    QTBPREF5TmpJc0ltVjRjQ0k2TVRjd01EUTVNVGsyTWl3aWFXRjBJam94TnpBd05EZ3dNall5TENK
    cGMzTWlPaUpCZW5WeVpTQkRiMjUwWVdsdVpYSWdVbVZuYVhOMGNua2lMQ0poZFdRaU9pSnRaV1Z3
    WVhCd0xtRjZkWEpsWTNJdWFXOGlMQ0oyWlhKemFXOXVJam9pTVM0d0lpd2ljbWxrSWpvaVl6YzBa
    alk0TXpneVl6RXdOREJpTWpsaFlXRTVZVEJoWXpoaU0yRXhNemtpTENKbmNtRnVkRjkwZVhCbElq
    b2ljbVZtY21WemFGOTBiMnRsYmlJc0ltRndjR2xrSWpvaU1EUmlNRGMzT1RVdE9HUmtZaTAwTmpG
    aExXSmlaV1V0TURKbU9XVXhZbVkzWWpRMklpd2lkR1Z1WVc1MElqb2lOalpsTURnNFpXSXRaRGN6
    TUMwME16UmhMVGt3T0dZdFpqaGhOamsxTkRVM016TXpJaXdpY0dWeWJXbHpjMmx2Ym5NaU9uc2lR
    V04wYVc5dWN5STZXeUp5WldGa0lpd2lkM0pwZEdVaUxDSmtaV3hsZEdVaUxDSmtaV3hsZEdWa0wz
    SmxZV1FpTENKa1pXeGxkR1ZrTDNKbGMzUnZjbVV2WVdOMGFXOXVJbDBzSWs1dmRFRmpkR2x2Ym5N
    aU9tNTFiR3g5TENKeWIyeGxjeUk2VzExOS5xSkUxUFNmX1RWRjBldGxyMklpSGxMU2JMUVYydVJ3
    NmhmN05OUXhXSmlibW1wSUpvcjJRNzdNWnBRY1dWMkVCVlllb1hsUUlZTWlnS01hNngxdUQ5ajNG
    THFfbzNiS2haTWo2R3o2d0J0STQzekhlaFZ6NjVLVURjUXgyYW5HUWpOeDFzdy1sbmttaXpyNERB
    TkZWRGEtdm8tMU5NdTRGUlV2TGk1OVhZSHQtODF2dVBQQ0lmOGlIUnM4MTBiMTVxSC1LczMzZWFV
    TjdaYWdud3BfNFZudi1qLUR5VHgxcUdIdE9RaDlWckR0Q0xRNzhiRDNDbngzajhDbm44M19CUDZp
    NnF1SjNOU3JEeEF1SURiMHZCbVNDaVRIX3dCU3NIRG82dDZsMllWV3gtYm5PVFc3OFFsNE93UFVz
    bGFHdWtEakpUMGxqSmNPNzFhSXpXU2cybXciCgkJfSwKCQkibWljcm92aXguYXp1cmVjci5pbyI6
    IHsKCQkJImF1dGgiOiAiYldsamNtOTJhWGc2YVhFNFpVRndia3BFY2tRNU9EWmlNMUJSUlVKNlBW
    bHhkVlpKTm5BMk9FRT0iCgkJfQoJfQp9