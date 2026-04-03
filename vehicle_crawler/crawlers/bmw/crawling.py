import requests
import json
import os

HEADERS = {
    "User-Agent": "Mozilla/5.0",
    "Accept": "application/json",
    "Cookie": "_fbp=fb.2.1774322776451.896530996494650149; WG_VER_CLIENT=V.21.2.24; _gcl_au=1.1.1107555843.1774322777; _ga=GA1.1.41342587.1774322778; cc_consentCookie=%7B%22bmw_korea_family%22%3A%7B%22cmm%22%3A%7B%22advertising%22%3A1%7D%2C%22cdc%22%3A1%2C%22tp%22%3A1763970144114%2C%22lmt%22%3A1774323789947%7D%7D; M-X-TOKEN=5adea3a5-014e-4249-9a1b-db55858da256; C5tM5s_origin=%7B%22sentAnomalies%22%3A%5B%5D%2C%22from%22%3A%22shop_bmw_co_kr%22%2C%22sid%22%3A%2225161983598195237657279108932712486050%22%7D; bmwdtm_hq_vs=1774839940; launchSession=R3mozC1BAB0; AMCVS_B52D1CFE5330949C0A490D45%40AdobeOrg=1; s_cc=true; oms_unique=true; WG_CLIENT_ID=LGn9yt38rJqb7ymoxjeX; nudgeDisplayed=true; bm_mi=E22C13E8C8DB08D9F4EA454C61001D75~YAAQFKPBF0YJiB2dAQAAmkK7Qx8q/6+ntADZ9Pfp79ifstJ9j2PlyQdj2c2m03E2zDKaw9XyNqQ7o4MAy0YSVsneYOuWyQNlfXl7y1eF418MZumIqcTZudJie3XcYk0Ok4Wog4snNYTe1pCCu/3MthLTt0AVvukb6Cb7SNCvcCkf9h8pjy75ziXa1cveIQyNMusv3SiqXo3plJ0QHwCgy9RQcf+vf571ZyYOXUUVQ2kt99Pgg7Bc8OjPt4sYLYd7ofXH++xisNkSN6Gs287hPLcJVpgJtuTxvXuc5zI+h7cwfy4JADe9Tkl1tjTUIUKqM1+eAaDMLcM=~1; AMCV_B52D1CFE5330949C0A490D45%40AdobeOrg=1176715910%7CMCMID%7C70948083600041638684130828339601276744%7CMCAAMLH-1775562642%7C11%7CMCAAMB-1775562642%7C6G1ynYcLPuiQxYZrsz_pkqfLG9yMXBpb2zX5dvJdYQJzPXImdj0y%7CMCOPTOUT-1774965042s%7CNONE%7CMCAID%7CNONE%7CvVersion%7C5.4.0%7CMCIDTS%7C20544; ak_bmsc=8890C998A997E30FE23046F3DB20417B~000000000000000000000000000000~YAAQFKPBF1dbiB2dAQAACqa7Qx/yKEQKLckJoVno01MtApeI2mUJa1+VmCQEw4MAKNqFeFY8/S112TPXb8wSlUkI2h85Ve5fj6H/iMMXTaEy21zNpFLwbtJZJ8w9u0HPZyt1aTaCe9ZiWDbqJCTqwDE4BBRdrKfCofR+Qfo5UFNbxGZ5beHuCqgDZYFOT6AO+DzRRZLov+1QgjjdhCADk0XDDM8Y4IkCECX1AsNZHalNgZLNjlycQu7JQPGvrVHnsNxK9zTAAKZ73Gr4k8nbgI/LQo5zWz3fA3jl7rdLPiel1GJb09Tkh6mx5QzHABik+1QzdXlw2GM89RcHhIHUhGjo7Sxi6xk/ZoAbDFfaUrnt1jIYP4lDaEcyn2U6Go14makZHvAHTgVX4CKGAP9HoRdfCtoZYfYaVVMbi9Ovf7jw4h8YqFLqBatS0QqocFygGnxiN0hY8QdxdfmLvcoXDHviW5HvJ0XTHx0O6/Vhh0R9a4iXmTNkG4yAtYF8J+SJuvTTVJUexxrz/w==; AKA_A2=A; bmwdtm_hq_sid=0.5360899694844358; bm_sv=AB36A6E1742C2B88439FDBAA9CC05B25~YAAQFaPBF0SPTh+dAQAA3v0CRB/fajhL7v4Y7uRjWhCt9Clk/N1ZjTxq4EUGRTufiA9K3cY1CRA+B7sLoLaQomAFwfYoh1LiY9K1/8wvjL2B3cWhMiHfHloDEef0yNKNhbf1dlFi3Dk8sriCwrWTU3adx5Bef0ipJdIRe92HuAGZSQZvigd85QjZD96F0v2HEkiMnY4Mny9Vdsax4lM3J9Umx0W6WzdoQLB4RFOAiWr6XkwnmcJ3EVIZKRiAWlXkWQ==~1; bmwdtm_hq_previouspage_meta=%257B%2522componentName%2522%253A%257B%2522currValue%2522%253A%2522stageX%2520aem%2520page%2522%257D%252C%2522pageSubCategory01%2522%253A%257B%2522currValue%2522%253A%2522content%2522%252C%2522prevValue%2522%253A%2522i%2520series%2522%257D%252C%2522pageName%2522%253A%257B%2522currValue%2522%253A%2522nsc%2520%253E%2520homepage%2522%252C%2522prevValue%2522%253A%2522nsc%2520%253E%2520ix-2025-i20bev%2522%257D%252C%2522url%2522%253A%257B%2522currValue%2522%253A%2522https%253A%252F%252Fwww.bmw.co.kr%252Fko%252Findex.html%2522%252C%2522prevValue%2522%253A%2522https%253A%252F%252Fwww.bmw.co.kr%252Fko%252Fall-models%252Fbmw-i%252Fix%252Fbmw-ix.html%2523technical-data%2522%257D%252C%2522componentSubcategory1%2522%253A%257B%2522currValue%2522%253A%2522content-page%2522%257D%252C%2522pathName%2522%253A%257B%2522currValue%2522%253A%2522https%253A%252F%252Fwww.bmw.co.kr%252Fko%252Findex.html%2522%252C%2522prevValue%2522%253A%2522https%253A%252F%252Fwww.bmw.co.kr%252Fko%252Fall-models%252Fbmw-i%252Fix%252Fbmw-ix.html%2522%257D%252C%2522eventEffect%2522%253A%257B%2522currValue%2522%253A%2522nsc%2520%253E%2520page%253A%2520homepage%2520shown%2522%252C%2522prevValue%2522%253A%2522nsc%2520%253E%2520bounce%2520timer%2522%257D%252C%2522pagePrimaryCategory%2522%253A%257B%2522currValue%2522%253A%2522homepage%2522%252C%2522prevValue%2522%253A%2522homepage%2522%257D%257D; s_sq=bmwgroup.group.global.all%252Cbmwgroup.bmw.kr.market%3D%2526c.%2526a.%2526activitymap.%2526page%253Dhttps%25253A%25252F%25252Fshop.bmw.co.kr%25252Freservation%25252Foim%25252FOIM26020001%2526link%253D%2525EC%25258A%2525A4%2525ED%25258F%2525AC%2525EC%2525B8%2525A0%252520%2525EC%25258A%2525A4%2525ED%25258B%2525B0%2525EC%252596%2525B4%2525EB%2525A7%252581%252520%2525ED%25259C%2525A0%2526region%253DWrap%2526.activitymap%2526.a%2526.c; s_ips=1148; s_tp=1148; s_ppv=https%253A%2F%2Fshop.bmw.co.kr%2Freservation%2Foim%2FOIM26020001%2C100%2C100%2C1148%2C1%2C1; _ga_1XM07VW7WF=GS2.1.s1774962568$o15$g1$t1774962825$j50$l0$h0; _dd_s=rum=2&id=87b08ee0-1459-4bbc-bd36-30417c69165a&created=1774962563952&expire=1774963725316&logs=1"
}

RAW_DIR = "data/raw"
DETAIL_DIR = "data/detail"

os.makedirs(DETAIL_DIR, exist_ok=True)

def fetch_detail(edition_id):
    url = f"https://shop.bmw.co.kr/shop/api/opm/{edition_id}"
    
    try:
        res = requests.get(url, headers=HEADERS)
        if res.status_code == 200:
            return res.json()
        else:
            print(f"❌ {edition_id} 실패: {res.status_code}")
            return None
    except Exception as e:
        print(f"❌ 에러: {edition_id}", e)
        return None


def run():
    files = [f for f in os.listdir(RAW_DIR) if f.endswith(".json")]

    for f in files:
        path = os.path.join(RAW_DIR, f)
        data = json.load(open(path, encoding="utf-8"))

        edition_id = data.get("edition_id")
        if not edition_id:
            continue

        detail = fetch_detail(edition_id)
        if not detail:
            continue

        save_path = os.path.join(DETAIL_DIR, f)
        with open(save_path, "w", encoding="utf-8") as out:
            json.dump(detail, out, ensure_ascii=False, indent=2)

        print(f"✅ 저장 완료: {edition_id}")


if __name__ == "__main__":
    run()